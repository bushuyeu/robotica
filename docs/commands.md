---
layout: default
title: Command Reference
nav_order: 4
---

# Command Reference

All commands are run from the `robotica/` root directory using [just](https://just.systems/).

---

## Setup & Verification

| Command | Description |
|---------|-------------|
| `just setup` | Run the bootstrap script (`setup.sh`) |
| `just check` | Verify all envs, models, checkpoints, and Docker |
| `just monitor-setup` | Create meta-repo venv with wandb + HF Hub |
| `just wandb-login` | Authenticate with Weights & Biases |
| `just hf-login` | Authenticate with Hugging Face Hub |

## Pipeline — Stage 1 (PromptHMR)

| Command | Description |
|---------|-------------|
| `just phmr-run <video>` | Extract 3D pose from a single video |
| `just phmr-batch` | Process all videos in `data/videos/` |

**Output:** `results/<video_name>/phmr_results.pkl`

PromptHMR automatically skips videos that already have results.

## Pipeline — Stage 2 (GMR Retarget)

| Command | Description |
|---------|-------------|
| `just gmr-retarget <video> [robot]` | Retarget to robot (default: `unitree_g1`) |
| `just gmr-batch [robot]` | Batch retarget all processed videos |

**Output:** `results/<video_name>/retarget_unitree_g1.pkl`

## Pipeline — Combined

| Command | Description |
|---------|-------------|
| `just pipeline <video> [robot]` | Run Stage 1 + Stage 2 for one video |
| `just pipeline-batch [robot]` | Batch Stage 1 + 2 for all videos |

## Pipeline — Monitored (wandb + HF Hub)

| Command | Description |
|---------|-------------|
| `just pipeline-monitored <video>` | Single video with wandb logging |
| `just pipeline-monitored-batch` | Batch with wandb logging + HF upload |
| `just auto-pipeline-monitored` | Drive sync + batch + wandb + HF upload |

Monitored recipes log to [wandb](https://wandb.ai/) with per-video metrics tables and batch summary scalars. The batch variant also uploads `.pkl` artifacts to Hugging Face Hub.

### wandb Metrics

| Metric | Type |
|--------|------|
| `results_table` | Table (per-video: name, status, durations, frame counts, file sizes, DOF stats) |
| `batch/total_videos` | Scalar |
| `batch/newly_processed` | Scalar |
| `batch/skipped` | Scalar |
| `batch/errors` | Scalar |
| `batch/total_duration_s` | Scalar |

## Pipeline — Stage 3 (GR00T-WBC Simulation)

| Command | Description |
|---------|-------------|
| `just groot-check` | Verify GR00T Docker image is available |
| `just groot-sim <video>` | Print Docker commands for interactive sim |
| `just groot-copy <video>` | Copy retarget `.pkl` to standalone GR00T repo |
| `just groot-copy-all` | Copy all retarget results to GR00T |

Stage 3 is interactive and requires two terminals inside Docker. See the [Reproduction Guide]({% link reproduction-guide.md %}#5-stage-3--simulate-in-groot-wbc) for full instructions.

## Google Drive Sync

| Command | Description |
|---------|-------------|
| `just drive-check` | Verify rclone + `gdrive` remote is configured |
| `just drive-list` | List Drive videos and local download status |
| `just drive-sync` | Download new videos from Google Drive |

## Automation

| Command | Description |
|---------|-------------|
| `just auto-pipeline [robot]` | Drive sync + pipeline batch + groot-copy-all |
| `just auto-pipeline-monitored` | Same as above, with wandb + HF upload |

## Utilities

| Command | Description |
|---------|-------------|
| `just results` | List all pipeline outputs |
| `just clean` | Delete all results (with confirmation prompt) |
