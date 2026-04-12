---
layout: default
title: Reproduction Guide
nav_order: 2
---

# Teleoperation from Recorded Video — Reproduction Guide

Step-by-step guide for reproducing upper-body teleoperation of the Unitree G1 robot from recorded video.

**Pipeline:** Video → PromptHMR (3D pose) → GMR (retarget) → GR00T-WBC (sim/hardware)

> Check the [Glossary](glossary.md) for definitions of technical terms used in this guide.

---

## What This Project Does

Imagine watching a video of someone waving their arms and having a robot copy those exact movements in real time. That is what this pipeline does. It takes an ordinary video of a person, figures out how their body is moving in 3D space, translates those movements into commands a robot can understand, and then replays the motion on a simulated Unitree G1 humanoid robot.

The technical term for controlling a robot by demonstrating motions yourself is **teleoperation**. Traditional teleoperation usually requires special suits, sensors, or joysticks strapped to the operator's body. This project replaces all of that hardware with a single video camera. You record yourself (or anyone) performing a motion, and the pipeline handles the rest.

The pipeline is split into three stages because each one solves a fundamentally different problem. **Stage 1 (PromptHMR)** watches the video and reconstructs a detailed 3D model of the human body — skeleton positions, joint angles, even finger poses — frame by frame. **Stage 2 (GMR)** takes that human skeleton and "retargets" it onto the robot's skeleton, which has different proportions, fewer joints, and mechanical limits that a human body does not have. **Stage 3 (GR00T-WBC)** loads the retargeted motion into a physics simulator, where a balance controller keeps the robot standing upright while its arms replay the recorded motion. If everything looks good in simulation, the same motion can be sent to a real robot.

You do not need a background in machine learning or robotics to follow this guide. Each stage is wrapped in a single command, and the setup script handles the heavy lifting of installing dependencies. That said, a basic comfort level with the Linux terminal (running commands, editing files) will make the process smoother.

---

## Prerequisites

- **Hardware:** Linux workstation with NVIDIA GPU (RTX 3090+, CUDA compute 8.6+)
- **Software:** git, curl, bash, ffmpeg, Docker, NVIDIA Container Toolkit
- **Accounts:** `gcloud` CLI with access to `gs://io-robotica` (or SMPL-X credentials at https://smpl-x.is.tue.mpg.de as fallback)
- **Package manager:** [uv](https://astral.sh/uv) (v0.10.2+)

**Disk space and time estimates:**

| Component | Disk Space | Notes |
|-----------|-----------|-------|
| PromptHMR checkpoints | ~8 GB | Downloaded by `setup.sh` |
| SMPL-X body models | ~1 GB | Pulled from GCS; symlinked between PromptHMR and GMR |
| GR00T-WBC Docker image | ~31 GB | Pulled during setup |
| Per-video results | ~50 MB | Stages 1 + 2 combined |
| **Total minimum** | **~50 GB** | Free disk before starting |

| Pipeline Stage | Time per Video |
|----------------|---------------|
| Stage 1 (PromptHMR) | ~10-30 min depending on video length and GPU |
| Stage 2 (GMR retarget) | ~1-2 min |
| Stage 3 (GR00T sim) | Real-time (interactive) |

```bash
# Install uv if not present
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# Install system dependencies
sudo apt update && sudo apt install -y git git-lfs curl ffmpeg

# Verify NVIDIA driver
nvidia-smi
```

### Setting up Docker with GPU support (required for Stage 3)

Stage 3 (GR00T-WBC) runs inside a Docker container that needs GPU access. If you already have `docker --version` and `nvidia-container-cli info` working, skip this section.

```bash
# Install Docker (official method)
curl -fsSL https://get.docker.com | sh

# Allow your user to run Docker without sudo (requires logout/login after)
sudo usermod -aG docker $USER
newgrp docker   # apply group change in current shell

# Install NVIDIA Container Toolkit (GPU access inside Docker)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt update && sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Verify GPU is visible inside Docker
docker run --rm --gpus all nvidia/cuda:12.6.0-base-ubuntu22.04 nvidia-smi
```

> **Common issue:** If you see "permission denied" when running `docker`, you need to log out and back in (or reboot) after the `usermod` command for the group change to take effect.

### Setting up Google Cloud access (recommended)

The fastest way to get body models and checkpoints is from our GCS bucket. If you don't have `gcloud`, `setup.sh` will fall back to manual downloads (slower, requires SMPL-X registration).

```bash
# Install the gcloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL   # restart shell to pick up gcloud

# Log in and verify bucket access
gcloud auth login
gcloud storage ls gs://io-robotica/   # should list bucket contents
```

If you **cannot get GCS access**, `setup.sh` will automatically fall back to:
- Downloading SMPL-X body models via interactive credentials (register at [smpl-x.is.tue.mpg.de](https://smpl-x.is.tue.mpg.de) — approval may take 1-2 days)
- Downloading checkpoints from Google Drive (may be rate-limited)

---

## 1. Clone the Meta-Repo

```bash
cd ~/Projects
git clone https://github.com/bushuyeu/robotica robotica && cd robotica
bash setup.sh    # clones sub-repos, creates venvs, installs deps, sets up symlinks
just check       # verify everything is set up (should show all [OK])
```

The `setup.sh` script is idempotent — safe to re-run if something fails partway through.

### What `setup.sh` does:
1. **Pre-flight checks** — verifies NVIDIA driver, git, git-lfs, curl, ffmpeg, disk space, gcloud auth
2. **Install uv** — Python package manager (if not already installed)
3. **Install just** — command runner (if not already installed)
4. **Clone repos** — PromptHMR, GMR, GR00T-WholeBodyControl from GitHub
5. **PromptHMR venv + deps** — creates Python 3.12 venv, installs PyTorch, custom wheels, and all dependencies
6. **PromptHMR data** — downloads body models and checkpoints from GCS bucket (or prompts for SMPL-X credentials as fallback)
7. **GMR venv + deps** — creates Python 3.12 venv, installs MuJoCo and dependencies
8. **Symlink body models** — links SMPL-X files from PromptHMR → GMR (avoids duplication)
9. **GR00T advisory** — prints Docker setup instructions (does **not** pull the image automatically)
10. **Shared directories + .env** — creates `data/videos/`, `results/`, and `.env` from template
11. **Meta-repo venv** — creates a venv for wandb and Hugging Face Hub integration

> **Why separate venvs?** PromptHMR, GMR, and GR00T-WBC have irreconcilable dependency trees — different PyTorch builds, different Python versions (3.12 vs 3.10), and conflicting transitive dependencies. A single environment cannot satisfy all three.

> **Why symlink body models?** The SMPL-X body model files are ~1 GB. Both PromptHMR and GMR need them, so `setup.sh` symlinks them from PromptHMR into GMR rather than downloading or storing a second copy.

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

> **Why headless batch mode?** PromptHMR can run without a display, making it suitable for batch processing over SSH. The `just phmr-batch` recipe processes all videos in `data/videos/` sequentially.

**Output:** `results/<video_name>/phmr_results.pkl`

Also saved in PromptHMR's own results dir:
- `PromptHMR/results/<video_name>/results.pkl` — full results dict (joblib-compressed)
- `PromptHMR/results/<video_name>/world4d.glb` — viewable in Blender
- `PromptHMR/results/<video_name>/world4d.mcs` — viewable at meshcapade.com/editor
- `PromptHMR/results/<video_name>/subject-*.smpl` — per-person SMPL codec

### What success looks like (Stage 1)

A successful run prints progress for each pipeline step (SPEC calibration, SAM2 tracking, DROID-SLAM, ViTPose, PromptHMR inference, world conversion, optimization) and finishes without errors. The final lines will show the post-optimization completing and results being saved.

**Expected files and sizes** (reference: `PXL_20260114_220015872`, a ~14s video):

| File | Location | Approx. Size |
|------|----------|-------------|
| `phmr_results.pkl` | `results/<video_name>/` | ~1.7 MB |
| `results.pkl` | `PromptHMR/results/<video_name>/` | ~1.7 MB |
| `world4d.glb` | `PromptHMR/results/<video_name>/` | ~65 MB |
| `world4d.mcs` | `PromptHMR/results/<video_name>/` | ~167 KB |
| `subject-1.smpl` | `PromptHMR/results/<video_name>/` | ~110 KB |

**How to verify the output:**
- Open `world4d.glb` in Blender — you should see a 3D human mesh replaying the motions from the video in world coordinates.
- Upload `world4d.mcs` to [meshcapade.com/editor](https://meshcapade.com/editor) for a quick browser-based preview.
- The `phmr_results.pkl` file should be loadable with `joblib.load()` and contain SMPL-X parameters (body pose, global orientation, translation) for each frame.

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

> **Why headless retargeting?** GMR supports headless mode (no MuJoCo viewer window), which allows batch processing over SSH without a display. The Justfile recipe uses this automatically.

**Output:** `results/<video_name>/retarget_unitree_g1.pkl`

The output contains:
- `fps`: frame rate (typically 30)
- `dof_pos`: joint angles `(T, 29)` — 29 degrees of freedom
- `root_pos`: root position `(T, 3)`
- `root_rot`: root rotation quaternion `(T, 4)`

### What success looks like (Stage 2)

The retargeting runs in under 2 minutes. Terminal output shows GMR loading the SMPL-X body model, reading the PromptHMR results, performing the joint-space optimization, and saving the retarget pickle. No errors or warnings should appear.

**Expected files and sizes** (reference: `PXL_20260114_220015872`):

| File | Location | Approx. Size |
|------|----------|-------------|
| `retarget_unitree_g1.pkl` | `results/<video_name>/` | ~123 KB |

**How to verify the output:**

```python
import pickle
with open("results/<video_name>/retarget_unitree_g1.pkl", "rb") as f:
    data = pickle.load(f)

print(data.keys())   # dict_keys(['fps', 'root_pos', 'root_rot', 'dof_pos'])
print(data["fps"])    # 30
print(data["root_pos"].shape)  # (T, 3)  — e.g. (428, 3)
print(data["root_rot"].shape)  # (T, 4)  — e.g. (428, 4)
print(data["dof_pos"].shape)   # (T, 29) — e.g. (428, 29)
```

- `T` is the number of frames (428 for a ~14 second video at 30 fps).
- `dof_pos` values should be in radians, typically in the range [-3.14, 3.14].
- `root_rot` should be unit quaternions (norm close to 1.0).

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

> **Why Docker for GR00T-WBC?** The GR00T whole-body controller requires ROS2 Humble, a specific MuJoCo version (3.2.6), NVIDIA toolkit integration, and Python 3.10 — a stack that is difficult to install natively alongside the other repos' Python 3.12 environments. Docker encapsulates this entirely.

### 5.1 Prepare X11 display

The MuJoCo viewer needs to open a graphical window. On Linux, this uses **X11** — a system that manages display output. Docker containers don't have their own display, so you need to share yours with the container.

> **Working over SSH?** You need X11 forwarding enabled: connect with `ssh -X user@host`. Alternatively, use a remote desktop (VNC, NoMachine) for better performance. Without a display server, the MuJoCo viewer cannot open.

On the **host** (not inside Docker), find your display and allow Docker access:

```bash
# Find your display number
echo $DISPLAY
# Example output: ":2" — if blank, you may not have a display server running

# Allow Docker to access your display
xhost +local:docker
```

### 5.2 Copy retarget results to Docker-accessible location

The Docker container mounts `~/Projects/GR00T-WholeBodyControl` (standalone path). Copy results there:

> **Why copy to a separate path?** The Docker container's volume mount points to the standalone `~/Projects/GR00T-WholeBodyControl` directory, not the `robotica/GR00T-WholeBodyControl` sub-repo. Files must be placed where Docker can see them.

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

> **Why `--speed 0.25`?** Playing back arm motions at full speed (1.0) generates torques that exceed what the balance policy can compensate for, causing the robot to fall. Quarter speed keeps motions within the stability envelope.

### 5.5 Activate the policy

In **Terminal 1** (the terminal running the control loop, NOT the viewer window):

1. Press `]` — activates the balance policy. You should see `Use policy action: True` printed.
2. Wait for the initial pose settle period (10 seconds).
3. The robot's arms should start replaying the video motion.

### What success looks like (Stage 3)

**Control loop (Terminal 1):**
- The MuJoCo viewer opens showing the Unitree G1 robot standing upright on a flat ground plane.
- After pressing `]`, the terminal prints `Use policy action: True`.
- The robot remains standing with slight leg micro-adjustments (this is the balance policy actively stabilizing — it is normal).

**Publisher (Terminal 2):**
- The publisher prints frame-by-frame publishing status as it sends joint targets.
- With `--speed 0.25`, the motion replays at quarter speed for stability.
- The `--loop` flag causes the motion to repeat indefinitely.

**In the MuJoCo viewer:**
- The robot stands on its own without falling (press `9` to release the elastic band after the initial pose settles).
- The robot's upper body (arms, torso) replays the motions from the original video.
- The legs remain planted and the robot maintains balance throughout.
- Some leg tremor on bent knees is normal and expected.

**How to verify it is working correctly:**
- The robot should NOT fall over when the elastic band is released (if it does, check that `upper_body_joint_speed` is 5.0, not 1000, in `configs.py`).
- The arm motions should visually correspond to the original video input.
- The simulation should run continuously without NaN warnings or freezes.

> **Why the elastic band?** The simulated robot starts suspended in the air by a virtual elastic band. This gives the balance policy time to initialize and reach a stable standing pose before gravity takes full effect. Releasing the band too early (before the policy activates) causes the robot to collapse.

> **Why keyboard in the terminal, not the viewer?** The control loop uses the `sshkeyboard` library, which reads keypresses from terminal stdin. The MuJoCo viewer is a separate window with its own input handling (e.g., `w` in the viewer toggles floor tiles). Robot commands only work in the terminal where `run_g1_control_loop.py` is running.

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
- **Robot falls when band released:** Ensure `upper_body_joint_speed` is set to 5.0 (not 1000) in `configs.py`. Use `--speed 0.25` for the publisher. The value must stay below the 6.0 rad/s arm velocity safety limit.
- **Simulation instability (NaN warnings):** Reduce motion speed (`--speed 0.1`) or restart the control loop.
- **`--sim-sync-mode` crashes:** Known issue. Use default async mode.
- **Segfault on viewer close:** Normal — closing the MuJoCo window causes this. Just restart the control loop.
- **Legs shaking on bent knees:** Normal — the balance policy is actively stabilizing. Safe to proceed.
- **`groups: cannot find name for group ID 994`:** Harmless Docker warning — can be safely ignored.
- **Command pasting breaks in Docker terminal:** Multi-line paste with backslash continuations can fail inside the container. Paste commands as a single line, or type them manually.
- **Retarget `.pkl` not found inside container:** The Docker container mounts `~/Projects/GR00T-WholeBodyControl` (standalone), not the `robotica` sub-repo. Make sure you copied the `.pkl` to the standalone repo's `resources/poses/` directory (see Section 5.2).

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
