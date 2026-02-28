# robotica

Meta-repo for the video-to-robot teleoperation pipeline.

```
Video → PromptHMR → GMR → GR00T → Unitree G1
        (3D pose)   (retarget)  (sim/hardware)
```

## Architecture

```
robotica/
├── setup.sh                 # One-command bootstrap
├── Justfile                 # All CLI recipes
├── .env                     # Sub-repo paths (auto-generated)
├── data/videos/             # Input videos
├── results/                 # Shared pipeline outputs
│   └── <video_name>/
│       ├── phmr_results.pkl     # Stage 1: 3D pose (SMPL-X)
│       └── retarget_*.pkl       # Stage 2: Robot joint angles
├── PromptHMR/               # Stage 1 — 3D human mesh recovery
├── GMR/                     # Stage 2 — Joint retargeting
└── GR00T-WholeBodyControl/  # Stage 3 — Sim & hardware replay
```

## Prerequisites

- Linux with NVIDIA GPU (CUDA 12.6+)
- `git`, `curl`, `bash`
- SMPL-X credentials (register at https://smpl-x.is.tue.mpg.de)

## Quickstart

```bash
git clone <this-repo> robotica && cd robotica
bash setup.sh       # clones repos, creates venvs, installs deps
just check           # verify everything is set up
```

## Commands

| Command | Description |
|---------|-------------|
| `just setup` | Run bootstrap script |
| `just check` | Verify envs, models, checkpoints |
| `just phmr-run <video>` | Extract 3D pose from video |
| `just phmr-batch` | Process all videos in `data/videos/` |
| `just gmr-retarget <video> [robot]` | Retarget to robot (default: `unitree_g1`) |
| `just gmr-batch [robot]` | Batch retarget all processed videos |
| `just pipeline <video> [robot]` | Full Stage 1 + 2 |
| `just pipeline-batch [robot]` | Batch full pipeline |
| `just groot-sim <video>` | Print GR00T Docker instructions |
| `just results` | List all outputs |
| `just clean` | Delete results (with confirmation) |

## Data Flow

1. Place videos in `data/videos/`
2. `just phmr-run data/videos/my_video.mp4` — produces `results/my_video/phmr_results.pkl`
3. `just gmr-retarget data/videos/my_video.mp4` — produces `results/my_video/retarget_unitree_g1.pkl`
4. `just groot-sim data/videos/my_video.mp4` — prints Docker commands for simulation

## Notes

- Each sub-repo has its own venv (conflicting PyTorch versions)
- PromptHMR skips processing if results already exist
- GR00T runs inside Docker — `setup.sh` prints instructions but does not install it
- Body models are symlinked from PromptHMR → GMR (no duplication)
