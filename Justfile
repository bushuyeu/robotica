set dotenv-load
set shell := ["bash", "-euo", "pipefail", "-c"]

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

# Run PromptHMR on a single video
phmr-run video:
    #!/usr/bin/env bash
    set -euo pipefail
    VIDEO="{{video}}"
    ABS_VIDEO="$(realpath "$VIDEO")"
    NAME="$(basename "${VIDEO%.*}")"

    # Check if results already exist
    if [ -f "$PHMR_DIR/results/$NAME/results.pkl" ]; then
        echo "[SKIP] Results already exist: $PHMR_DIR/results/$NAME/results.pkl"
        # Copy to shared results dir
        mkdir -p "$RESULTS_DIR/$NAME"
        cp -u "$PHMR_DIR/results/$NAME/results.pkl" "$RESULTS_DIR/$NAME/phmr_results.pkl"
        exit 0
    fi

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
    VIDEO="{{video}}"
    ROBOT="{{robot}}"
    NAME="$(basename "${VIDEO%.*}")"

    PHMR_RESULTS="$PHMR_DIR/results/$NAME/results.pkl"
    if [ ! -f "$PHMR_RESULTS" ]; then
        # Try shared results dir
        PHMR_RESULTS="$RESULTS_DIR/$NAME/phmr_results.pkl"
    fi
    if [ ! -f "$PHMR_RESULTS" ]; then
        echo "[ERROR] No PromptHMR results for $NAME. Run: just phmr-run $VIDEO"
        exit 1
    fi

    ABS_RESULTS="$(realpath "$PHMR_RESULTS")"
    OUT_DIR="$(cd . && pwd)/$RESULTS_DIR/$NAME"
    OUT_FILE="$OUT_DIR/retarget_${ROBOT}.pkl"

    if [ -f "$OUT_FILE" ]; then
        echo "[SKIP] Retarget results already exist: $OUT_FILE"
        exit 0
    fi

    echo "[RUN] GMR retarget → $NAME ($ROBOT)"
    mkdir -p "$OUT_DIR"
    (
        cd "$GMR_DIR"
        .venv/bin/python scripts/prompthmr_to_robot.py \
            --results_file "$ABS_RESULTS" \
            --robot "$ROBOT" \
            --save_path "$OUT_FILE"
    )
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
    just phmr-run {{video}}
    just gmr-retarget {{video}} {{robot}}

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

# GR00T simulation — advisory only
groot-sim video:
    #!/usr/bin/env bash
    echo "═══ GR00T Simulation ═══"
    echo ""
    echo "GR00T-WholeBodyControl runs inside Docker."
    echo ""
    echo "1. Start the container:"
    echo "   cd $GROOT_DIR"
    echo "   ./docker/run_docker.sh --install --root"
    echo ""
    NAME="$(basename "{{video}}" | sed 's/\.[^.]*$//')"
    RETARGET="$(realpath "$RESULTS_DIR/$NAME/retarget_unitree_g1.pkl" 2>/dev/null || echo "$RESULTS_DIR/$NAME/retarget_unitree_g1.pkl")"
    echo "2. Inside the container, run:"
    echo "   python gr00t_wbc/control/main/teleop/publish_upper_body_from_results.py \\"
    echo "       --results $RETARGET \\"
    echo "       --loop --teleop-frequency 30 --hand-mode zero \\"
    echo "       --speed 0.5 --initial-pose-seconds 5.0 --upper-body-only"

# List all pipeline results
results:
    #!/usr/bin/env bash
    set -euo pipefail
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
