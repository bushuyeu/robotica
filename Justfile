set dotenv-load
set shell := ["bash", "-euo", "pipefail", "-c"]

# Google Drive shared video folder ID
DRIVE_FOLDER_ID := "11I9UZfqr_JanmgzVx3qM0zNF3YzqaEuW"
# Google Doc ID for the shared quick-ref document
QUICKREF_DOC_ID := "1nB0O2PMIJ1lYWeAb37TYOTPj7q0LIIlm7W_WJAsrYX8"
# Standalone GR00T repo mounted by Docker (override via .env or env var)
GROOT_STANDALONE := env_var_or_default("GROOT_STANDALONE", env("HOME") / "Projects/GR00T-WholeBodyControl")

# Default: list available recipes
default:
    @just --list

# Run the bootstrap script
setup:
    bash setup.sh

# Verify all envs, models, and checkpoints
check:
    #!/usr/bin/env bash
    set -euo pipefail
    GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
    ok()  { echo -e "${GREEN}[OK]${NC} $1"; }
    fail(){ echo -e "${RED}[FAIL]${NC} $1"; ERRORS=$((ERRORS+1)); }
    ERRORS=0

    echo "═══ Checking sub-repos ═══"
    for dir in "$PHMR_DIR" "$GMR_DIR" "$GROOT_DIR"; do
        [ -d "$dir" ] && ok "$dir exists" || fail "$dir missing"
    done

    echo ""
    echo "═══ Checking venvs ═══"
    [ -d "$PHMR_DIR/.venv" ] && ok "PromptHMR venv" || fail "PromptHMR venv missing"
    [ -d "$GMR_DIR/.venv" ]  && ok "GMR venv"       || fail "GMR venv missing"

    echo ""
    echo "═══ Checking key packages ═══"
    "$PHMR_DIR/.venv/bin/python" -c "import torch; print(f'  torch {torch.__version__}')" 2>/dev/null \
        && ok "PromptHMR torch" || fail "PromptHMR torch not installed"
    "$GMR_DIR/.venv/bin/python" -c "import mujoco" 2>/dev/null \
        && ok "GMR mujoco" || fail "GMR mujoco not installed"

    echo ""
    echo "═══ Checking body models ═══"
    [ -f "$PHMR_DIR/data/body_models/smplx/SMPLX_NEUTRAL.pkl" ] \
        && ok "SMPL-X models" || fail "SMPL-X models missing (run: bash setup.sh)"

    echo ""
    echo "═══ Checking checkpoints ═══"
    [ -f "$PHMR_DIR/data/pretrain/vitpose-h-coco_25.pth" ] \
        && ok "PromptHMR checkpoints" || fail "PromptHMR checkpoints missing"

    echo ""
    echo "═══ Checking GMR symlinks ═══"
    [ -L "$GMR_DIR/assets/body_models/smplx/SMPLX_NEUTRAL.pkl" ] \
        && ok "GMR body model symlinks" || fail "GMR symlinks missing"

    echo ""
    echo "═══ Checking GR00T Docker ═══"
    # Try rootless docker first, then fall back to sudo -n (non-interactive)
    # because run_docker.sh --install --root installs the image into root's
    # daemon, which a non-docker-group user can't inspect without sudo.
    docker_has_image() {
        docker image inspect "$1" >/dev/null 2>&1 \
            || sudo -n docker image inspect "$1" >/dev/null 2>&1
    }
    if ! command -v docker &>/dev/null; then
        fail "Docker not installed (see https://docs.docker.com/engine/install/)"
    elif docker_has_image gr00t_wbc-deploy-root \
        || docker_has_image nvgear/gr00t_wbc:latest; then
        ok "GR00T Docker image"
    else
        fail "GR00T Docker image missing (run: cd $GROOT_DIR && ./docker/run_docker.sh --install --root)"
    fi

    echo ""
    echo "═══ Checking data dirs ═══"
    [ -d "$VIDEO_DIR" ]   && ok "$VIDEO_DIR"   || fail "$VIDEO_DIR missing"
    [ -d "$RESULTS_DIR" ] && ok "$RESULTS_DIR" || fail "$RESULTS_DIR missing"

    echo ""
    if [ $ERRORS -eq 0 ]; then
        echo -e "${GREEN}All checks passed.${NC}"
    else
        echo -e "${RED}$ERRORS check(s) failed.${NC}"
        exit 1
    fi

# Guided first run: check → pick a video → Stage 1 → Stage 2 → Stage 3 instructions
quickstart:
    #!/usr/bin/env bash
    set -euo pipefail
    GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

    echo "═══ Quickstart: Guided First Run ═══"
    echo ""

    # Step 1: Verify setup
    echo "── Step 1/4: Checking setup ──"
    if ! just check; then
        echo ""
        echo -e "${RED}Setup checks failed. Run 'bash setup.sh' first.${NC}"
        exit 1
    fi

    echo ""
    echo "── Step 2/4: Finding a video ──"
    shopt -s nullglob
    VIDEOS=("$VIDEO_DIR"/*.{mp4,avi,mov,mkv,MP4,AVI,MOV,MKV})
    if [ ${#VIDEOS[@]} -eq 0 ]; then
        echo -e "${YELLOW}No videos found in $VIDEO_DIR${NC}"
        echo ""
        echo "To get started, place a video file in the data/videos/ directory:"
        echo "  cp /path/to/your/video.mp4 data/videos/"
        echo ""
        echo "Or download a sample from the team pool:"
        echo "  https://drive.google.com/drive/folders/11I9UZfqr_JanmgzVx3qM0zNF3YzqaEuW"
        exit 0
    fi

    VIDEO="${VIDEOS[0]}"
    NAME="$(basename "${VIDEO%.*}")"
    echo -e "${GREEN}Found ${#VIDEOS[@]} video(s). Using first: $NAME${NC}"

    # Step 3: Stage 1 — PromptHMR
    echo ""
    echo "── Step 3/4: Stage 1 — Extract 3D pose (PromptHMR) ──"
    if [ -f "$RESULTS_DIR/$NAME/phmr_results.pkl" ]; then
        echo -e "${GREEN}[SKIP]${NC} PromptHMR results already exist for $NAME"
    else
        echo "This may take 10-30 minutes depending on video length and GPU."
        echo ""
        just phmr-run "$VIDEO"
    fi

    # Step 4: Stage 2 — GMR retarget
    echo ""
    echo "── Step 4/4: Stage 2 — Retarget to robot (GMR) ──"
    if [ -f "$RESULTS_DIR/$NAME/retarget_unitree_g1.pkl" ]; then
        echo -e "${GREEN}[SKIP]${NC} Retarget results already exist for $NAME"
    else
        just gmr-retarget "$VIDEO"
    fi

    # Done — print Stage 3 instructions
    echo ""
    echo "═══════════════════════════════════════"
    echo -e "${GREEN}Stages 1 & 2 complete for: $NAME${NC}"
    echo "═══════════════════════════════════════"
    echo ""
    echo "Results:"
    echo "  $RESULTS_DIR/$NAME/phmr_results.pkl          (3D pose)"
    echo "  $RESULTS_DIR/$NAME/retarget_unitree_g1.pkl   (robot joints)"
    echo ""
    echo "Next: Stage 3 — Simulate in GR00T-WBC (requires Docker + two terminals)."
    echo "Run this for instructions:"
    echo "  just groot-sim $VIDEO"
    echo ""
    echo "Or see the full guide: docs/reproduction-guide.md, Section 5"

# Run PromptHMR on a single video
phmr-run video:
    #!/usr/bin/env bash
    set -euo pipefail
    RED='\033[0;31m'; NC='\033[0m'
    if [ ! -f .env ] || [ -z "${PHMR_DIR:-}" ]; then
        echo -e "${RED}[ERROR]${NC} .env file missing or incomplete. Run: bash setup.sh"
        exit 1
    fi
    VIDEO="{{video}}"
    ABS_VIDEO="$(realpath "$VIDEO")"
    NAME="$(basename "${VIDEO%.*}")"

    # Check if results already exist and are complete
    if [ -f "$RESULTS_DIR/$NAME/phmr_results.pkl.done" ]; then
        echo "[SKIP] Results already exist: $RESULTS_DIR/$NAME/phmr_results.pkl"
        exit 0
    fi

    # Clean up partial results from previous failed runs
    rm -f "$PHMR_DIR/results/$NAME/results.pkl" "$RESULTS_DIR/$NAME/phmr_results.pkl"

    echo "[RUN] PromptHMR → $NAME"
    (
        cd "$PHMR_DIR"
        .venv/bin/python scripts/demo_video.py \
            --input_video "$ABS_VIDEO" \
            --no-run_viser
    )

    # Copy results to shared dir
    mkdir -p "$RESULTS_DIR/$NAME"
    cp "$PHMR_DIR/results/$NAME/results.pkl" "$RESULTS_DIR/$NAME/phmr_results.pkl"

    # Validate before marking complete (blocks .done on bad data)
    .venv/bin/python -m robotica.validate phmr "$RESULTS_DIR/$NAME/phmr_results.pkl"

    touch "$RESULTS_DIR/$NAME/phmr_results.pkl.done"
    echo "[DONE] Results → $RESULTS_DIR/$NAME/phmr_results.pkl"

# Batch-run PromptHMR on all videos
phmr-batch:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    VIDEOS=("$VIDEO_DIR"/*.{mp4,avi,mov,mkv})
    if [ ${#VIDEOS[@]} -eq 0 ]; then
        echo "No videos found in $VIDEO_DIR"
        exit 1
    fi
    echo "Found ${#VIDEOS[@]} video(s)"
    for v in "${VIDEOS[@]}"; do
        just phmr-run "$v"
    done

# Retarget PromptHMR output to robot via GMR
gmr-retarget video robot="unitree_g1":
    #!/usr/bin/env bash
    set -euo pipefail
    RED='\033[0;31m'; NC='\033[0m'
    if [ ! -f .env ] || [ -z "${GMR_DIR:-}" ]; then
        echo -e "${RED}[ERROR]${NC} .env file missing or incomplete. Run: bash setup.sh"
        exit 1
    fi
    VIDEO="{{video}}"
    ROBOT="{{robot}}"
    NAME="$(basename "${VIDEO%.*}")"

    OUT_DIR="$(cd . && pwd)/$RESULTS_DIR/$NAME"
    OUT_FILE="$OUT_DIR/retarget_${ROBOT}.pkl"

    # Check if results already exist and are complete
    if [ -f "$OUT_FILE.done" ]; then
        echo "[SKIP] Retarget results already exist: $OUT_FILE"
        exit 0
    fi

    # Require completed PromptHMR results (not partial)
    PHMR_RESULTS="$RESULTS_DIR/$NAME/phmr_results.pkl"
    if [ ! -f "$PHMR_RESULTS.done" ]; then
        # Fall back to PromptHMR-local dir (for manually produced results)
        PHMR_RESULTS="$PHMR_DIR/results/$NAME/results.pkl"
    fi
    if [ ! -f "$PHMR_RESULTS" ]; then
        echo "[ERROR] No PromptHMR results for $NAME. Run: just phmr-run $VIDEO"
        exit 1
    fi

    # Clean up partial retarget results from previous failed runs
    rm -f "$OUT_FILE"

    ABS_RESULTS="$(realpath "$PHMR_RESULTS")"
    echo "[RUN] GMR retarget → $NAME ($ROBOT)"
    mkdir -p "$OUT_DIR"
    (
        cd "$GMR_DIR"
        .venv/bin/python scripts/prompthmr_to_robot.py \
            --results_file "$ABS_RESULTS" \
            --robot "$ROBOT" \
            --save_path "$OUT_FILE"
    )

    # Validate before marking complete (blocks .done on bad data)
    .venv/bin/python -m robotica.validate retarget "$OUT_FILE"

    touch "$OUT_FILE.done"
    echo "[DONE] Retarget → $OUT_FILE"

# Batch retarget all processed videos
gmr-batch robot="unitree_g1":
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    VIDEOS=("$VIDEO_DIR"/*.{mp4,avi,mov,mkv})
    if [ ${#VIDEOS[@]} -eq 0 ]; then
        echo "No videos found in $VIDEO_DIR"
        exit 1
    fi
    for v in "${VIDEOS[@]}"; do
        just gmr-retarget "$v" "{{robot}}"
    done

# Full pipeline: PromptHMR + GMR retarget
pipeline video robot="unitree_g1":
    just phmr-run "{{video}}"
    just gmr-retarget "{{video}}" "{{robot}}"

# Batch full pipeline
pipeline-batch robot="unitree_g1":
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    VIDEOS=("$VIDEO_DIR"/*.{mp4,avi,mov,mkv})
    if [ ${#VIDEOS[@]} -eq 0 ]; then
        echo "No videos found in $VIDEO_DIR"
        exit 1
    fi
    for v in "${VIDEOS[@]}"; do
        just pipeline "$v" "{{robot}}"
    done

# Verify GR00T Docker image is available
groot-check:
    #!/usr/bin/env bash
    set -euo pipefail
    GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
    if ! command -v docker &>/dev/null; then
        echo -e "${RED}[FAIL]${NC} Docker not installed"
        echo "  Install: https://docs.docker.com/engine/install/"
        exit 1
    elif docker image inspect gr00t_wbc-deploy-root >/dev/null 2>&1 \
        || docker image inspect nvgear/gr00t_wbc:latest >/dev/null 2>&1; then
        echo -e "${GREEN}[OK]${NC} GR00T Docker image found"
    else
        echo -e "${RED}[FAIL]${NC} GR00T Docker image missing. Run: cd $GROOT_DIR && ./docker/run_docker.sh --install --root"
        exit 1
    fi

# GR00T simulation — interactive Docker session
# Requires two terminals: one for the control loop, one for the publisher.
# This recipe prints the exact commands to run.
groot-sim video:
    #!/usr/bin/env bash
    set -euo pipefail
    NAME="$(basename "{{video}}" | sed 's/\.[^.]*$//')"
    RETARGET="$RESULTS_DIR/$NAME/retarget_unitree_g1.pkl"
    if [ ! -f "$RETARGET" ]; then
        echo "[ERROR] No retarget results: $RETARGET"
        echo "Run first: just gmr-retarget {{video}}"
        exit 1
    fi
    ABS_RETARGET="$(realpath "$RETARGET")"
    ABS_GROOT="$(realpath "$GROOT_DIR")"
    ABS_RESULTS="$(realpath "$RESULTS_DIR")"

    echo "═══ GR00T Simulation ═══"
    echo ""
    echo "This requires TWO terminals inside the same Docker container."
    echo ""
    echo "1. Start the container (Terminal 1):"
    echo "   cd $GROOT_DIR && ./docker/run_docker.sh --root"
    echo ""
    echo "2. Inside Terminal 1, start the control loop:"
    echo "   export PATH=/root/venv/bin:\$PATH && source /opt/ros/humble/setup.bash"
    echo "   python gr00t_wbc/control/main/teleop/run_g1_control_loop.py"
    echo ""
    echo "3. In Terminal 2, attach to the same container:"
    echo "   docker exec -it gr00t_wbc-bash-root /bin/bash"
    echo ""
    echo "4. Inside Terminal 2, publish the motion:"
    echo "   export PATH=/root/venv/bin:\$PATH && source /opt/ros/humble/setup.bash"
    echo "   python gr00t_wbc/control/main/teleop/publish_upper_body_from_results.py \\"
    echo "       --results /root/Projects/results/$NAME/retarget_unitree_g1.pkl \\"
    echo "       --loop --teleop-frequency 30 --hand-mode zero \\"
    echo "       --speed 0.25 --initial-pose-seconds 10.0 --upper-body-only"
    echo ""
    echo "5. In Terminal 1 (NOT the viewer), press ']' to activate, wait 5s, then press '9' to release elastic band."

# List all pipeline results
results:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    echo "═══ Pipeline Results ═══"
    echo ""

    echo "── PromptHMR outputs ──"
    if ls "$PHMR_DIR"/results/*/results.pkl 1>/dev/null 2>&1; then
        for f in "$PHMR_DIR"/results/*/results.pkl; do
            dir="$(dirname "$f")"
            name="$(basename "$dir")"
            size="$(du -sh "$f" | cut -f1)"
            echo "  $name  ($size)"
        done
    else
        echo "  (none)"
    fi

    echo ""
    echo "── Shared results ──"
    if [ -d "$RESULTS_DIR" ] && [ "$(ls -A "$RESULTS_DIR" 2>/dev/null)" ]; then
        for dir in "$RESULTS_DIR"/*/; do
            name="$(basename "$dir")"
            files="$(ls "$dir" 2>/dev/null | tr '\n' ', ' | sed 's/,$//')"
            echo "  $name: $files"
        done
    else
        echo "  (none)"
    fi

# ═══════════════════════════════════════════════════════════
# Google Drive sync & auto-pipeline recipes
# ═══════════════════════════════════════════════════════════

# Verify rclone is installed and gdrive remote is configured
drive-check:
    #!/usr/bin/env bash
    set -euo pipefail
    GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

    if ! command -v rclone &>/dev/null; then
        echo -e "${RED}[FAIL]${NC} rclone is not installed."
        echo "  Install: curl https://rclone.org/install.sh | sudo bash"
        exit 1
    fi
    echo -e "${GREEN}[OK]${NC} rclone $(rclone version --check 2>/dev/null | head -1 || rclone version 2>/dev/null | head -1)"

    if ! rclone listremotes 2>/dev/null | grep -q '^gdrive:'; then
        echo -e "${RED}[FAIL]${NC} rclone remote 'gdrive' is not configured."
        echo "  Run: rclone config"
        echo "  Create a new remote named 'gdrive' with type 'drive' and scope 'drive.readonly'"
        exit 1
    fi
    echo -e "${GREEN}[OK]${NC} rclone remote 'gdrive' configured"

# List videos in Google Drive and show local download status
drive-list:
    #!/usr/bin/env bash
    set -euo pipefail
    GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

    just drive-check

    echo ""
    echo "═══ Videos in Google Drive ═══"
    echo ""

    # List remote video files
    REMOTE_FILES=$(rclone lsf "gdrive:" \
        --drive-root-folder-id "{{DRIVE_FOLDER_ID}}" \
        --include "*.{mp4,avi,mov,mkv,MP4,AVI,MOV,MKV}" 2>/dev/null || true)

    if [ -z "$REMOTE_FILES" ]; then
        echo "  (no video files found in Drive folder)"
        exit 0
    fi

    TOTAL=0
    LOCAL=0
    while IFS= read -r file; do
        [ -z "$file" ] && continue
        TOTAL=$((TOTAL + 1))
        if [ -f "$VIDEO_DIR/$file" ]; then
            echo -e "  ${GREEN}[LOCAL]${NC} $file"
            LOCAL=$((LOCAL + 1))
        else
            echo -e "  ${RED}[REMOTE]${NC} $file"
        fi
    done <<< "$REMOTE_FILES"

    echo ""
    echo "$LOCAL/$TOTAL videos downloaded locally"

# Download new videos from Google Drive to data/videos/
drive-sync:
    #!/usr/bin/env bash
    set -euo pipefail
    GREEN='\033[0;32m'; NC='\033[0m'

    just drive-check

    echo ""
    echo "═══ Syncing videos from Google Drive ═══"
    echo ""

    mkdir -p "$VIDEO_DIR"

    rclone copy "gdrive:" "$VIDEO_DIR" \
        --drive-root-folder-id "{{DRIVE_FOLDER_ID}}" \
        --include "*.{mp4,avi,mov,mkv,MP4,AVI,MOV,MKV}" \
        --progress \
        --verbose

    echo ""
    echo -e "${GREEN}[DONE]${NC} Videos synced to $VIDEO_DIR"

# Copy retarget .pkl to standalone GR00T repo for Docker access
groot-copy video:
    #!/usr/bin/env bash
    set -euo pipefail
    GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
    NAME="$(basename "{{video}}" | sed 's/\.[^.]*$//')"

    SRC="$RESULTS_DIR/$NAME/retarget_unitree_g1.pkl"
    DST="{{GROOT_STANDALONE}}/resources/poses/$NAME.pkl"

    if [ ! -f "$SRC.done" ]; then
        echo -e "${RED}[ERROR]${NC} No completed retarget results: $SRC"
        echo "  Run first: just pipeline {{video}}"
        exit 1
    fi

    if [ -f "$DST" ]; then
        echo "[SKIP] Already copied: $DST"
        exit 0
    fi

    mkdir -p "$(dirname "$DST")"
    cp "$SRC" "$DST"
    echo -e "${GREEN}[DONE]${NC} Copied $NAME.pkl → {{GROOT_STANDALONE}}/resources/poses/"

# Copy all retarget results to standalone GR00T repo for Docker access
groot-copy-all:
    #!/usr/bin/env bash
    set -euo pipefail
    GREEN='\033[0;32m'; NC='\033[0m'
    shopt -s nullglob

    PKLS=("$RESULTS_DIR"/*/retarget_unitree_g1.pkl.done)
    if [ ${#PKLS[@]} -eq 0 ]; then
        echo "No completed retarget results found in $RESULTS_DIR"
        exit 0
    fi

    COPIED=0
    SKIPPED=0
    INCOMPLETE=0
    for done_file in "${PKLS[@]}"; do
        pkl="${done_file%.done}"
        NAME="$(basename "$(dirname "$pkl")")"
        DST="{{GROOT_STANDALONE}}/resources/poses/$NAME.pkl"
        if [ ! -f "$pkl" ]; then
            echo "[WARN] .done marker without .pkl: $pkl"
            INCOMPLETE=$((INCOMPLETE + 1))
        elif [ -f "$DST" ]; then
            SKIPPED=$((SKIPPED + 1))
        else
            mkdir -p "$(dirname "$DST")"
            cp "$pkl" "$DST"
            echo -e "${GREEN}[COPIED]${NC} $NAME.pkl"
            COPIED=$((COPIED + 1))
        fi
    done

    echo ""
    echo "Copied $COPIED, skipped $SKIPPED (already existed)${INCOMPLETE:+, $INCOMPLETE warnings}"

# Full auto-pipeline: drive-sync → pipeline-batch → groot-copy-all
auto-pipeline robot="unitree_g1":
    #!/usr/bin/env bash
    set -euo pipefail
    GREEN='\033[0;32m'; NC='\033[0m'
    shopt -s nullglob

    echo "═══ Auto Pipeline ═══"
    echo ""

    # Count videos before sync
    BEFORE=("$VIDEO_DIR"/*.{mp4,avi,mov,mkv,MP4,AVI,MOV,MKV})
    BEFORE_COUNT=${#BEFORE[@]}

    # Step 1: Sync from Drive
    echo "── Step 1/3: Syncing videos from Google Drive ──"
    just drive-sync

    # Count videos after sync
    AFTER=("$VIDEO_DIR"/*.{mp4,avi,mov,mkv,MP4,AVI,MOV,MKV})
    AFTER_COUNT=${#AFTER[@]}
    SYNCED=$((AFTER_COUNT - BEFORE_COUNT))

    # Step 2: Run pipeline on all videos
    echo ""
    echo "── Step 2/3: Running PromptHMR + GMR pipeline ──"
    just pipeline-batch "{{robot}}"

    # Step 3: Copy results to GR00T
    echo ""
    echo "── Step 3/3: Copying retarget results to GR00T ──"
    just groot-copy-all

    # Summary
    RETARGETS=("$RESULTS_DIR"/*/retarget_unitree_g1.pkl)
    echo ""
    echo "═══ Summary ═══"
    echo -e "${GREEN}  Videos synced:${NC}      $SYNCED new (${AFTER_COUNT} total)"
    echo -e "${GREEN}  Videos processed:${NC}   ${#RETARGETS[@]} with retarget results"
    echo -e "${GREEN}  GR00T poses:${NC}        $(ls {{GROOT_STANDALONE}}/resources/poses/*.pkl 2>/dev/null | wc -l) files in standalone repo"

# ═══════════════════════════════════════════════════════════
# Monitored pipeline recipes (wandb + HF Hub)
# ═══════════════════════════════════════════════════════════

# Set up meta-repo venv with wandb + huggingface-hub
monitor-setup:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -d .venv ]; then
        uv venv --python 3.12
    fi
    uv pip install -e .
    echo "[OK] Meta-repo venv ready with wandb + huggingface-hub"

# Login to wandb
wandb-login:
    .venv/bin/wandb login

# Login to Hugging Face Hub
hf-login:
    .venv/bin/hf auth login

# Single video with wandb monitoring
pipeline-monitored video robot="unitree_g1" wandb_project="robotica":
    .venv/bin/python -m robotica.pipeline_monitor \
        --video "{{video}}" --robot "{{robot}}" --wandb-project "{{wandb_project}}"

# Batch pipeline with wandb monitoring + HF upload
pipeline-monitored-batch robot="unitree_g1" wandb_project="robotica":
    .venv/bin/python -m robotica.pipeline_monitor \
        --robot {{robot}} --wandb-project {{wandb_project}} --hf-upload

# Full auto-pipeline with Drive sync + wandb + optional HF upload
auto-pipeline-monitored robot="unitree_g1" wandb_project="robotica":
    .venv/bin/python -m robotica.pipeline_monitor \
        --robot {{robot}} --wandb-project {{wandb_project}} \
        --drive-sync --hf-upload

# Download latest version of the shared quick-ref Google Doc into notes/
sync-notes:
    #!/usr/bin/env bash
    set -euo pipefail
    GREEN='\033[0;32m'; NC='\033[0m'
    mkdir -p notes
    curl -sL "https://docs.google.com/document/d/{{QUICKREF_DOC_ID}}/export?format=txt" \
        -o notes/g1-quick-ref-and-links.txt
    echo -e "${GREEN}[DONE]${NC} notes/g1-quick-ref-and-links.txt updated ($(wc -l < notes/g1-quick-ref-and-links.txt) lines)"

# Delete all results (with confirmation)
clean:
    #!/usr/bin/env bash
    echo "This will delete:"
    echo "  - $RESULTS_DIR/*"
    echo "  - $PHMR_DIR/results/*"
    echo ""
    read -rp "Are you sure? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$RESULTS_DIR"/*
        rm -rf "$PHMR_DIR"/results/*
        echo "Cleaned."
    else
        echo "Aborted."
    fi
