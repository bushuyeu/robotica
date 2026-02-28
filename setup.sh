#!/usr/bin/env bash
# robotica — idempotent bootstrap script
# Usage: bash setup.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; }
info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; }

# ── A: Install uv ───────────────────────────────────────────────────────────
echo ""
echo "═══ A: uv ═══"
if command -v uv &>/dev/null; then
    skip "uv already installed ($(uv --version))"
else
    info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    ok "uv installed ($(uv --version))"
fi

# ── B: Install just ─────────────────────────────────────────────────────────
echo ""
echo "═══ B: just ═══"
if command -v just &>/dev/null; then
    skip "just already installed ($(just --version))"
else
    info "Installing just to ~/.local/bin..."
    mkdir -p ~/.local/bin
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
    export PATH="$HOME/.local/bin:$PATH"
    ok "just installed ($(just --version))"
fi

# ── C: Clone repos ──────────────────────────────────────────────────────────
echo ""
echo "═══ C: Clone repos ═══"

clone_repo() {
    local dir="$1" url="$2" upstream="${3:-}"
    if [ -d "$dir" ]; then
        skip "$dir already exists"
    else
        info "Cloning $url → $dir..."
        git clone "$url" "$dir"
        if [ -n "$upstream" ]; then
            git -C "$dir" remote add upstream "$upstream" 2>/dev/null || true
        fi
        ok "Cloned $dir"
    fi
}

clone_repo PromptHMR \
    https://github.com/haw-ai-i/PromptHMR.git \
    https://github.com/yufu-wang/PromptHMR.git

clone_repo GMR \
    https://github.com/haw-ai-i/GMR.git

clone_repo GR00T-WholeBodyControl \
    https://github.com/YosubShin/GR00T-WholeBodyControl.git \
    https://github.com/NVlabs/GR00T-WholeBodyControl.git

if [ -d GR00T-WholeBodyControl ]; then
    (cd GR00T-WholeBodyControl && git lfs install 2>/dev/null || true)
fi

# ── D: PromptHMR venv + deps ────────────────────────────────────────────────
echo ""
echo "═══ D: PromptHMR venv + deps ═══"
PHMR="$SCRIPT_DIR/PromptHMR"

if [ -d "$PHMR/.venv" ]; then
    skip "PromptHMR venv already exists"
else
    info "Creating PromptHMR venv (Python 3.12)..."
    (cd "$PHMR" && uv venv --python 3.12)
    ok "PromptHMR venv created"
fi

# Check if torch is already installed as a proxy for "deps installed"
if "$PHMR/.venv/bin/python" -c "import torch" 2>/dev/null; then
    skip "PromptHMR deps already installed"
else
    info "Installing PromptHMR dependencies (this may take a while)..."
    (
        cd "$PHMR"
        export VIRTUAL_ENV="$PHMR/.venv"
        export PATH="$VIRTUAL_ENV/bin:$PATH"

        # PyTorch + xformers + torch-scatter
        uv pip install torch==2.6.0 torchvision==0.21.0 \
            --index-url https://download.pytorch.org/whl/cu126
        uv pip install -U xformers==0.0.29.post2 \
            --index-url https://download.pytorch.org/whl/cu126 --no-deps
        uv pip install torch-scatter \
            -f https://data.pyg.org/whl/torch-2.6.0+cu126.html

        # Main requirements
        uv pip install -r requirements.txt

        # chumpy (editable, legacy)
        if [ ! -d python_libs/chumpy ]; then
            git clone https://github.com/Arthur151/chumpy python_libs/chumpy
        fi
        uv pip install -e python_libs/chumpy --no-build-isolation

        # Custom wheels (download from Google Drive if missing)
        if [ ! -d data/wheels ]; then
            info "Downloading custom wheels..."
            uv run gdown --folder -O ./data/ \
                https://drive.google.com/drive/folders/151gPvMaUWok_pDQT6h8Rpvk_rCcKvcWZ?usp=sharing
        fi

        # Fix gloss conflict and install wheels
        uv pip uninstall gloss gloss-rs 2>/dev/null || true
        uv pip install data/wheels/gloss_rs-0.6.0-cp38-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
        uv pip install \
            data/wheels/detectron2-0.9-cp312-cp312-linux_x86_64.whl \
            data/wheels/droid_backends_intr-0.4-cp312-cp312-linux_x86_64.whl \
            data/wheels/sam2-1.6-cp312-cp312-linux_x86_64.whl \
            data/wheels/lietorch-0.4-cp312-cp312-linux_x86_64.whl
    )
    ok "PromptHMR deps installed"
fi

# ── E: PromptHMR body models + checkpoints ──────────────────────────────────
echo ""
echo "═══ E: PromptHMR body models + checkpoints ═══"

if [ -f "$PHMR/data/body_models/smplx/SMPLX_NEUTRAL.pkl" ]; then
    skip "SMPL-X body models already present"
else
    info "Body models not found. Running interactive fetch script..."
    info "You will be prompted for SMPL-X and SMPL credentials."
    info "(Register at https://smpl-x.is.tue.mpg.de and https://smpl.is.tue.mpg.de)"
    echo ""
    (cd "$PHMR" && bash scripts/fetch_smplx.sh)
    ok "Body models fetched"
fi

if [ -f "$PHMR/data/pretrain/vitpose-h-coco_25.pth" ]; then
    skip "PromptHMR checkpoints already present"
else
    info "Downloading PromptHMR checkpoints and pretrained models..."
    (
        cd "$PHMR"
        export VIRTUAL_ENV="$PHMR/.venv"
        export PATH="$VIRTUAL_ENV/bin:$PATH"
        bash scripts/fetch_data.sh
    )
    ok "PromptHMR checkpoints fetched"
fi

# ── F: GMR venv + deps ──────────────────────────────────────────────────────
echo ""
echo "═══ F: GMR venv + deps ═══"
GMR="$SCRIPT_DIR/GMR"

if [ -d "$GMR/.venv" ]; then
    skip "GMR venv already exists"
else
    info "Creating GMR venv (Python 3.12)..."
    (cd "$GMR" && uv venv --python 3.12)
    ok "GMR venv created"
fi

if "$GMR/.venv/bin/python" -c "import mujoco" 2>/dev/null; then
    skip "GMR deps already installed"
else
    info "Installing GMR dependencies..."
    (
        cd "$GMR"
        export VIRTUAL_ENV="$GMR/.venv"
        export PATH="$VIRTUAL_ENV/bin:$PATH"
        uv pip install -e .
        uv pip install joblib
    )
    ok "GMR deps installed"
fi

# ── G: Symlink SMPL-X body models → GMR ─────────────────────────────────────
echo ""
echo "═══ G: Symlink body models → GMR ═══"
GMR_MODELS="$GMR/assets/body_models/smplx"

if [ -L "$GMR_MODELS/SMPLX_NEUTRAL.pkl" ]; then
    skip "SMPL-X symlinks already exist in GMR"
else
    mkdir -p "$GMR_MODELS"
    for f in SMPLX_NEUTRAL.pkl SMPLX_FEMALE.pkl SMPLX_MALE.pkl; do
        src="$PHMR/data/body_models/smplx/$f"
        if [ -f "$src" ]; then
            ln -sf "$src" "$GMR_MODELS/$f"
            ok "Linked $f → GMR"
        else
            err "$src not found — run section E first"
        fi
    done
fi

# ── H: GR00T advisory ───────────────────────────────────────────────────────
echo ""
echo "═══ H: GR00T-WholeBodyControl ═══"
info "GR00T uses Docker. To set up:"
echo "  cd GR00T-WholeBodyControl"
echo "  ./docker/run_docker.sh --install --root    # pull + start container"
echo "  ./docker/run_docker.sh --root               # re-enter container"
echo ""
info "See GR00T-WholeBodyControl/README.md for details."

# ── I: Shared directories + .env ─────────────────────────────────────────────
echo ""
echo "═══ I: Shared directories + .env ═══"
mkdir -p data/videos results

if [ ! -f .env ]; then
    cp .env.example .env
    ok "Created .env from .env.example"
else
    skip ".env already exists"
fi

# Move any videos from old location
if [ -f data/PXL_20260114_220015872.mp4 ]; then
    mv data/PXL_20260114_220015872.mp4 data/videos/
    ok "Moved video to data/videos/"
fi

echo ""
echo "═══════════════════════════════════════"
echo -e "${GREEN}Bootstrap complete!${NC}"
echo "Next steps:"
echo "  just check       — verify everything"
echo "  just phmr-run <video>  — run PromptHMR"
echo "═══════════════════════════════════════"
