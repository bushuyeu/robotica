# Teleoperation from Recorded Video — Reproduction Guide

Step-by-step guide for reproducing upper-body teleoperation of the Unitree G1 robot from recorded video.

**Pipeline:** Video → PromptHMR (3D pose) → GMR (retarget) → GR00T-WBC (sim/hardware)

---

## Prerequisites

- **Hardware:** Linux workstation with NVIDIA GPU (RTX 3090+, CUDA compute 8.6+)
- **Software:** git, curl, bash, ffmpeg, Docker, NVIDIA Container Toolkit
- **Accounts:** SMPL-X model credentials (register at https://smpl-x.is.tue.mpg.de)
- **Package manager:** [uv](https://astral.sh/uv) (v0.10.2+)

```bash
# Install uv if not present
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env

# Install system dependencies
sudo apt update && sudo apt install -y ffmpeg

# Verify Docker + NVIDIA
docker --version
nvidia-container-cli info
```

---

## 1. Clone the Meta-Repo

```bash
cd ~/Projects
git clone <robotica-repo-url> robotica && cd robotica
bash setup.sh    # clones sub-repos, creates venvs, installs deps, sets up symlinks
just check       # verify everything is set up (should show all [OK])
```

The `setup.sh` script is idempotent — safe to re-run if something fails partway through.

### What `setup.sh` does:
1. Clones PromptHMR, GMR, GR00T-WholeBodyControl from `haw-ai-i` GitHub
2. Creates separate Python venvs for PromptHMR (Python 3.12) and GMR (Python 3.12)
3. Installs all dependencies including custom wheels
4. Downloads body models (SMPL/SMPL-X) — will prompt for credentials
5. Downloads checkpoints and pretrained models
6. Symlinks body models from PromptHMR → GMR
7. Pulls the GR00T Docker image

---

## 2. Prepare Input Video

Place your video file in `data/videos/`:

```bash
cp /path/to/your/video.mp4 data/videos/
```

**Video requirements:**
- Format: MP4, AVI, MOV, or MKV
- Should contain a visible person performing motions
- Good lighting, person not too far from camera
- Max resolution will be capped at 896px height internally

Videos from the team pool: https://drive.google.com/drive/folders/11I9UZfqr_JanmgzVx3qM0zNF3YzqaEuW

---

## 3. Stage 1 — Extract 3D Pose (PromptHMR)

```bash
just phmr-run data/videos/your_video.mp4
```

This runs the full PromptHMR pipeline:
1. Load frames, resize, cap at 60fps
2. SPEC camera calibration (estimate intrinsics)
3. Person detection, segmentation, tracking (SAM2 + Detectron2)
4. Camera motion estimation (DROID-SLAM + Metric3D)
5. 2D keypoint estimation (ViTPose-H)
6. 3D human mesh recovery (PromptHMR_Video → SMPL-X)
7. World coordinate conversion
8. Post-optimization with contact constraints

**Runtime:** ~10-30 minutes per video depending on length and GPU.

**Output:** `results/<video_name>/phmr_results.pkl`

Also saved in PromptHMR's own results dir:
- `PromptHMR/results/<video_name>/results.pkl` — full results dict (joblib-compressed)
- `PromptHMR/results/<video_name>/world4d.glb` — viewable in Blender
- `PromptHMR/results/<video_name>/world4d.mcs` — viewable at meshcapade.com/editor
- `PromptHMR/results/<video_name>/subject-*.smpl` — per-person SMPL codec

### Batch processing

```bash
# Process all videos in data/videos/
just phmr-batch
```

### Troubleshooting

- **Google Drive rate limits on checkpoint download:** Download files manually via browser. See the [Notion setup guide](https://www.notion.so/313897fbdce381879b26f6ee3d1a1d9e) for manual download links and paths.
- **Python version errors:** Python 3.12 is required. Python 3.11 causes binary incompatibility with pre-compiled wheels.
- **Already processed:** The recipe skips videos that already have results.

---

## 4. Stage 2 — Retarget to Robot (GMR)

```bash
just gmr-retarget data/videos/your_video.mp4
```

This maps the 55-joint SMPL-X human skeleton to the Unitree G1's joint space.

**Output:** `results/<video_name>/retarget_unitree_g1.pkl`

The output contains:
- `fps`: frame rate (typically 30)
- `dof_pos`: joint angles `(T, 29)` — 29 degrees of freedom
- `root_pos`: root position `(T, 3)`
- `root_rot`: root rotation quaternion `(T, 4)`

### Options

```bash
# Retarget with visualization (default)
just gmr-retarget data/videos/your_video.mp4

# Specify a different robot
just gmr-retarget data/videos/your_video.mp4 unitree_h1

# Batch retarget all videos
just gmr-batch
```

### Troubleshooting

- **Missing PromptHMR results:** Run Stage 1 first.
- **MuJoCo visualization:** A MuJoCo window shows the retargeted motion. Close it when done.

---

## 5. Stage 3 — Simulate in GR00T-WBC

This stage runs inside Docker and requires **two terminals**.

### 5.1 Prepare X11 display

On the **host** (not inside Docker), find your display and allow Docker access:

```bash
# Find your display number
xdpyinfo | head -2
# Example output: "name of display:    :2"

# Allow Docker to access display
export DISPLAY=:2    # use your actual display number
xhost +local:docker
```

### 5.2 Copy retarget results to Docker-accessible location

The Docker container mounts `~/Projects/GR00T-WholeBodyControl` (standalone path). Copy results there:

```bash
mkdir -p ~/Projects/GR00T-WholeBodyControl/resources/poses/
cp results/<video_name>/retarget_unitree_g1.pkl \
   ~/Projects/GR00T-WholeBodyControl/resources/poses/<video_name>.pkl
```

### 5.3 Terminal 1 — Start control loop

```bash
cd ~/Projects/robotica/GR00T-WholeBodyControl
./docker/run_docker.sh --root
# (enter sudo password if prompted)

# Inside the container:
python gr00t_wbc/control/main/teleop/run_g1_control_loop.py
```

A MuJoCo viewer window should open showing the G1 robot.

**If you get `Failed to open display :0`:**
```bash
export DISPLAY=:2    # match your host display
python gr00t_wbc/control/main/teleop/run_g1_control_loop.py
```

### 5.4 Terminal 2 — Publish upper body motion

Open a new terminal on the host, then attach to the same container:

```bash
docker exec -it gr00t_wbc-bash-root /bin/bash

# Inside the container:
python gr00t_wbc/control/main/teleop/publish_upper_body_from_results.py --results resources/poses/<video_name>.pkl --loop --teleop-frequency 30 --hand-mode zero --speed 0.25 --initial-pose-seconds 10.0 --upper-body-only
```

### 5.5 Activate the policy

In **Terminal 1** (the terminal running the control loop, NOT the viewer window):

1. Press `]` — activates the balance policy. You should see `Use policy action: True` printed.
2. Wait for the initial pose settle period (10 seconds).
3. The robot's arms should start replaying the video motion.

### Keyboard controls (press in Terminal 1, NOT the viewer)

| Key | Action |
|-----|--------|
| `]` | Activate policy |
| `o` | Deactivate policy |
| `9` | Toggle elastic band (release/hold robot) |
| `w/s` | Forward/backward velocity (+/- 0.2) |
| `a/d` | Strafe left/right |
| `q/e` | Rotate left/right |
| `z` | Zero all navigation commands |
| `1/2` | Raise/lower base height |
| `` ` `` | Emergency stop |

### Known issues

- **Robot hangs in air:** The elastic band is enabled by default. Press `9` in the terminal (not viewer) to release it. Wait for the initial pose to settle first.
- **Robot falls when band released:** Ensure `upper_body_joint_speed` is set to 100 (not 1000) in `configs.py`. Use `--speed 0.25` for the publisher. The default 1000 rad/s moves arms too fast for the balance policy to compensate.
- **Simulation instability (NaN warnings):** Reduce motion speed (`--speed 0.1`) or restart the control loop.
- **`--sim-sync-mode` crashes:** Known issue. Use default async mode.
- **Segfault on viewer close:** Normal — closing the MuJoCo window causes this. Just restart the control loop.
- **Legs shaking on bent knees:** Normal — the balance policy is actively stabilizing. Safe to proceed.

---

## 6. Quick Reference

### Full pipeline for a single video

```bash
# Stage 1 + 2
just pipeline data/videos/my_video.mp4

# Stage 3 (manual — see Section 5)
just groot-sim data/videos/my_video.mp4
```

### Check pipeline status

```bash
just check      # verify envs and dependencies
just results    # list all processed outputs
```

### All processed results

```
results/
└── <video_name>/
    ├── phmr_results.pkl        # Stage 1: 3D pose (SMPL-X)
    └── retarget_unitree_g1.pkl # Stage 2: Robot joint angles
```

---

## Appendix: Architecture

Each sub-repo has its own virtual environment due to irreconcilable dependencies:

| Repo | Python | PyTorch | Notes |
|------|--------|---------|-------|
| PromptHMR | 3.12 | 2.6.0+cu126 | Custom wheels, xformers |
| GMR | 3.12 | (via mujoco) | MuJoCo, smplx |
| GR00T-WBC | 3.10 (Docker) | 2.6.0+cu124 | ROS2 Humble, MuJoCo 3.2.6 |

Body models (SMPL-X) are symlinked from PromptHMR → GMR to avoid duplication.

GR00T-WBC runs exclusively inside Docker (`nvgear/gr00t_wbc:latest`, ~31GB image).
