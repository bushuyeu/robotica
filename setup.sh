#!/usr/bin/env bash
# robotica — idempotent bootstrap script
# Usage: bash setup.sh [--force]
#   --force  re-run all sections even if they appear complete
set -euo pipefail

FORCE=false
if [ "${1:-}" = "--force" ]; then
    FORCE=true
fi

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

ERRORS=0
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
preflight_fail() { echo -e "${RED}[FAIL]${NC} $1"; ERRORS=$((ERRORS + 1)); }

# ── Pre-flight checks ──────────────────────────────────────────────────────
echo ""
echo "═══ Pre-flight checks ═══"

# NVIDIA driver / GPU
if command -v nvidia-smi &>/dev/null; then
    NVIDIA_OUTPUT=$(nvidia-smi 2>/dev/null)
    DRIVER_VER=$(echo "$NVIDIA_OUTPUT" | grep -oP 'Driver Version: \K[\d.]+' || echo "unknown")
    CUDA_VER=$(echo "$NVIDIA_OUTPUT" | grep -oP 'CUDA Version: \K[\d.]+' || echo "unknown")
    ok "NVIDIA driver $DRIVER_VER (CUDA $CUDA_VER)"
else
    preflight_fail "nvidia-smi not found — NVIDIA driver required (https://docs.nvidia.com/cuda/cuda-installation-guide-linux/)"
fi

# git
if command -v git &>/dev/null; then
    ok "git $(git --version | awk '{print $3}')"
else
    preflight_fail "git not found (run: sudo apt install git)"
fi

# git-lfs
if command -v git-lfs &>/dev/null; then
    ok "git-lfs $(git-lfs --version | awk '{print $1}' | cut -d/ -f2)"
else
    preflight_fail "git-lfs not found — required for GR00T model files (run: sudo apt install git-lfs)"
fi

# curl
if command -v curl &>/dev/null; then
    ok "curl"
else
    preflight_fail "curl not found (run: sudo apt install curl)"
fi

# ffmpeg
if command -v ffmpeg &>/dev/null; then
    ok "ffmpeg"
else
    preflight_fail "ffmpeg not found — required for video processing (run: sudo apt install ffmpeg)"
fi

# Disk space (need ~50 GB free)
FREE_GB=$(df -BG "$SCRIPT_DIR" | awk 'NR==2 {gsub(/G/,"",$4); print $4}')
if [ "$FREE_GB" -ge 50 ] 2>/dev/null; then
    ok "${FREE_GB} GB free disk space"
elif [ "$FREE_GB" -ge 30 ] 2>/dev/null; then
    warn "${FREE_GB} GB free — setup needs ~50 GB total; may run out during large downloads"
else
    preflight_fail "Only ${FREE_GB} GB free — need at least 50 GB (checkpoints, models, Docker image)"
fi

# gcloud (optional but preferred)
HAS_GCLOUD=false
if command -v gcloud &>/dev/null; then
    GCLOUD_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | head -1)
    if [ -n "$GCLOUD_ACCOUNT" ]; then
        ok "gcloud authenticated as $GCLOUD_ACCOUNT"
        HAS_GCLOUD=true
    else
        warn "gcloud installed but not authenticated — run: gcloud auth login"
        info "Will fall back to manual SMPL-X credential download and Google Drive"
    fi
else
    info "gcloud CLI not found — will use fallback download methods"
    info "  (Install gcloud: https://cloud.google.com/sdk/docs/install)"
fi

if [ $ERRORS -gt 0 ]; then
    echo ""
    err "$ERRORS pre-flight check(s) failed. Fix the issues above before continuing."
    exit 1
fi

echo ""
echo -e "${GREEN}Pre-flight checks passed.${NC}"

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
    (cd GR00T-WholeBodyControl && git lfs install)
    ok "git-lfs initialized for GR00T"
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

# Check if all key deps are installed (torch + custom wheels)
if [ "$FORCE" = false ] && "$PHMR/.venv/bin/python" -c "import torch; import detectron2; import chumpy" 2>/dev/null; then
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

        # chumpy (editable, legacy — needs pip in env for its setup.py)
        # The repo tracks python_libs/chumpy as a gitlink — remove and re-clone
        if [ ! -f python_libs/chumpy/setup.py ]; then
            rm -rf python_libs/chumpy
            git clone https://github.com/Arthur151/chumpy python_libs/chumpy
        fi
        uv pip install pip
        uv pip install -e python_libs/chumpy --no-build-isolation

        # Custom wheels (pull from GCS or fall back to Google Drive)
        if [ ! -d data/wheels ]; then
            if [ "$HAS_GCLOUD" = true ]; then
                info "Downloading custom wheels from GCS..."
                gcloud storage cp -r gs://io-robotica/PromptHMR/data/wheels "$PHMR/data/"
            else
                info "Downloading custom wheels from Google Drive..."
                uv pip install "gdown>=5.0"
                uv run gdown --folder -O ./data/ \
                    https://drive.google.com/drive/folders/151gPvMaUWok_pDQT6h8Rpvk_rCcKvcWZ?usp=sharing
            fi
        fi

        # Validate wheels downloaded successfully
        EXPECTED_WHEELS=(gloss_rs detectron2 droid_backends_intr sam2 lietorch)
        MISSING_WHEELS=()
        for w in "${EXPECTED_WHEELS[@]}"; do
            if ! ls data/wheels/${w}-*.whl &>/dev/null; then
                MISSING_WHEELS+=("$w")
            fi
        done
        if [ ${#MISSING_WHEELS[@]} -gt 0 ]; then
            err "Missing wheels: ${MISSING_WHEELS[*]}"
            err "Download failed or was rate-limited. Manual download:"
            err "  https://drive.google.com/drive/folders/151gPvMaUWok_pDQT6h8Rpvk_rCcKvcWZ"
            err "  Place .whl files in: $PHMR/data/wheels/"
            exit 1
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

# ── E: PromptHMR data (body models + checkpoints) ───────────────────────────
echo ""
echo "═══ E: PromptHMR data (body models + checkpoints) ═══"
GCS_BUCKET="gs://io-robotica/PromptHMR/data"

if [ "$FORCE" = false ] && [ -f "$PHMR/data/body_models/smplx/SMPLX_NEUTRAL.pkl" ] \
    && [ -f "$PHMR/data/pretrain/vitpose-h-coco_25.pth" ]; then
    skip "PromptHMR data already present (body models + checkpoints)"
else
    if [ "$HAS_GCLOUD" = true ]; then
        info "Pulling PromptHMR data from GCS bucket..."
        gcloud storage cp -r "$GCS_BUCKET/body_models" "$PHMR/data/"
        gcloud storage cp -r "$GCS_BUCKET/pretrain" "$PHMR/data/"
        ok "PromptHMR data fetched from GCS"
    else
        info "gcloud not available — falling back to interactive fetch scripts"
        info "You will be prompted for SMPL-X and SMPL credentials."
        info "(Register at https://smpl-x.is.tue.mpg.de and https://smpl.is.tue.mpg.de)"
        echo ""
        (cd "$PHMR" && bash scripts/fetch_smplx.sh)
        ok "Body models fetched"
        info "Downloading PromptHMR checkpoints and pretrained models..."
        (
            cd "$PHMR"
            export VIRTUAL_ENV="$PHMR/.venv"
            export PATH="$VIRTUAL_ENV/bin:$PATH"
            bash scripts/fetch_data.sh
        )
        ok "PromptHMR checkpoints fetched"
    fi

    # Validate critical files were downloaded
    if [ ! -f "$PHMR/data/body_models/smplx/SMPLX_NEUTRAL.pkl" ]; then
        err "SMPL-X body models missing after download"
        err "  Manual fix: download from https://smpl-x.is.tue.mpg.de"
        err "  Place SMPLX_NEUTRAL.pkl in: $PHMR/data/body_models/smplx/"
        exit 1
    fi
    if [ ! -f "$PHMR/data/pretrain/vitpose-h-coco_25.pth" ]; then
        err "PromptHMR checkpoints missing after download"
        err "  Manual fix: see PromptHMR/scripts/fetch_data.sh for download URLs"
        exit 1
    fi
    ok "PromptHMR data validated"
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

if [ "$FORCE" = false ] && "$GMR/.venv/bin/python" -c "import mujoco" 2>/dev/null; then
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

# ── J: Meta-repo venv (wandb + HF Hub) ───────────────────────────────────────
echo ""
echo "═══ J: Meta-repo venv (wandb + HF Hub) ═══"
if [ -d "$SCRIPT_DIR/.venv" ]; then
    skip "Meta-repo venv already exists"
else
    info "Creating meta-repo venv (Python 3.12)..."
    (cd "$SCRIPT_DIR" && uv venv --python 3.12)
    ok "Meta-repo venv created"
fi

if "$SCRIPT_DIR/.venv/bin/python" -c "import wandb" 2>/dev/null; then
    skip "Meta-repo deps already installed"
else
    info "Installing meta-repo dependencies (wandb, huggingface-hub)..."
    (cd "$SCRIPT_DIR" && uv pip install -e .)
    ok "Meta-repo deps installed"
fi

echo ""
echo "═══════════════════════════════════════"
echo -e "${GREEN}Bootstrap complete!${NC}"
echo "Next steps:"
echo "  just check       — verify everything"
echo "  just phmr-run <video>  — run PromptHMR"
echo "  just wandb-login       — authenticate wandb"
echo "  just hf-login          — authenticate HF Hub"
echo "═══════════════════════════════════════"
