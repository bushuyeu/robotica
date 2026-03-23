---
layout: default
title: Hardware Deployment
nav_order: 3
---

# Hardware Deployment Guide — Unitree G1

Step-by-step guide for deploying the video-to-robot teleoperation pipeline on a physical Unitree G1 humanoid.

**Prerequisite:** Complete the [Reproduction Guide](reproduction-guide.md) first. You should have a working sim pipeline (Stages 1-3) before attempting hardware deployment.

> Check the [Glossary](glossary.md) for definitions of technical terms used in this guide.

---

## What Changes Between Sim and Hardware

The GR00T-WBC control loop supports both simulation and real hardware through a single `--interface` flag. When you switch from `--interface sim` (the default) to `--interface real`, the following things change:

| Aspect | Simulation (`sim`) | Hardware (`real`) |
|--------|-------------------|------------------|
| Communication | Loopback DDS (local) | CycloneDDS over Ethernet UDP |
| Physics | MuJoCo simulates gravity, contacts, motors | Real motors, real gravity, real consequences |
| Odometry | Full state from sim | Disabled (position fixed at [0,0,0]) |
| Waist pitch KD | Default value | Reduced by factor of 10 (sim2real gap compensation) |
| Hand calibration | Skipped | Runs automatically on startup |
| Locomotion controller | Not present | Must be explicitly released via remote controller |
| Joint velocity violations | Warning only | Hard exit (`sys.exit(1)`) |
| Elastic band | Virtual spring holds robot | Not applicable — use physical harness instead |

The motion publisher (`publish_upper_body_from_results.py`) is identical in both modes. It publishes joint targets over DDS regardless of whether the control loop is talking to a simulator or real hardware.

---

## Prerequisites Checklist

### Hardware

- [ ] Unitree G1 humanoid robot (powered off)
- [ ] Unitree remote controller (fully charged)
- [ ] Ethernet cable (Cat5e or better)
- [ ] Linux workstation with NVIDIA GPU (same machine used for sim)
- [ ] Physical suspension frame or overhead harness with shoulder buckles
- [ ] Clear workspace — at minimum 2m x 2m around the robot, no fragile objects
- [ ] **A second person** to act as safety operator (holds remote controller, ready to e-stop)

### Software (should already be installed from sim setup)

- [ ] GR00T-WBC Docker image (`gr00t_wbc-deploy-root:latest`)
- [ ] Retarget `.pkl` file from Stage 2 of the pipeline
- [ ] Unitree SDK2 (bundled inside the Docker image)
- [ ] CycloneDDS (bundled inside the Docker image)

### Power

- [ ] Robot battery fully charged (46.8V 9000mAh, approximately 2 hours runtime)
- [ ] Workstation plugged into mains power (not battery)

---

## 1. Network Setup

The workstation communicates with the G1 over a direct Ethernet connection. The robot has two RJ45 ports on its neck — use either one.

### 1.1 Connect the cable

Plug an Ethernet cable from the robot's neck RJ45 port to your workstation's Ethernet port.

### 1.2 Configure the workstation network interface

Find your Ethernet interface name:

```bash
ip link show
```

Look for the interface that is plugged in (state `UP` or `DOWN` but physically connected). Common names are `eth0`, `enp3s0`, `eno1`, etc. Wireless interfaces (`wlan0`, `wlp*`) are not what you want.

Configure it with the required static IP:

```bash
# Replace <IFACE> with your Ethernet interface name (e.g., enp3s0)
sudo ip link set <IFACE> up
sudo ip addr flush dev <IFACE>
sudo ip addr add 192.168.123.222/24 dev <IFACE>
```

### 1.3 Verify connectivity

The robot must be powered on for this step (see Section 2). Once it is booted:

```bash
ping -c 3 192.168.123.164
```

You should see replies. If not:
- Check the cable is firmly seated in both ends.
- Verify you configured the correct interface (not your WiFi adapter).
- Verify the robot has finished booting (wait ~1 minute after power on).

### 1.4 Verify SSH access (optional but recommended)

```bash
ssh unitree@192.168.123.164
# Password: 123
```

This confirms bidirectional network access. Exit the SSH session before proceeding.

---

## 2. Robot Startup Procedure

**Use the hanging method** — suspend the robot from its shoulder buckles so its feet are off the ground. This prevents falls during initialization and gives you a safe window to verify everything before the robot bears its own weight.

### 2.1 Suspend the robot

Attach the robot's shoulder buckles to the suspension frame or overhead harness. The robot's feet should hang freely, not touching the ground.

### 2.2 Power on

1. **Short press** the power button (just a tap).
2. **Long press** the power button for 2+ seconds.
3. Wait approximately 1 minute for the onboard computer to boot.

### 2.3 Enter debug/develop mode

Using the Unitree remote controller:

1. Press **L2 + B** — puts the robot in **damping mode** (soft stop, all joints gently resist motion).
2. Press **L2 + R2** — puts the robot in **debug/develop mode**. This releases Unitree's built-in locomotion controller, handing joint control over to the SDK.

> **Why release the locomotion controller?** The G1 ships with a built-in locomotion controller that claims exclusive access to the motors. GR00T-WBC communicates directly with the motors via SDK2, so the built-in controller must be released first. The `--interface real` code does this automatically via `MotionSwitcherClient`, but entering debug mode via the remote controller ensures a clean handoff.

### 2.4 Verify connectivity

From the workstation:

```bash
ping -c 3 192.168.123.164
```

If this works, the robot is booted and the network is ready.

---

## 3. Deployment Procedure

The following example uses video `PXL_20260114_214954286` throughout. Replace with your video name as needed.

### 3.1 Prepare the retarget results

Copy all retarget `.pkl` files to the Docker-accessible location. From the host:

```bash
cd ~/Projects/robotica

# Copy a single video
just groot-copy PXL_20260114_214954286

# Or copy all processed videos at once
just groot-copy-all
```

Then copy to the Docker-mounted path (the Docker container mounts `~/Projects/robotica/GR00T-WholeBodyControl`, not the standalone directory):

```bash
cp ~/Projects/GR00T-WholeBodyControl/resources/poses/PXL_*.pkl \
   ~/Projects/robotica/GR00T-WholeBodyControl/resources/poses/
```

### 3.2 Find your Ethernet interface name

Before starting Docker, identify your Ethernet interface:

```bash
ip link show
```

Look for the interface connected to the robot (e.g., `enp39s0`). You will need this name for the `--interface` flag.

### 3.3 Terminal 1 — Start the control loop (hardware mode)

Enable X11 forwarding for Docker, then start the deploy container with the specific interface name and flags:

```bash
xhost +local:docker

cd ~/Projects/robotica/GR00T-WholeBodyControl && ./docker/run_docker.sh --deploy --root --interface enp39s0 --no-with_hands --no-data_collection --no-enable_upper_body_operation --no-enable_webcam_recording --no-view_camera
```

> **Note:** Pass the actual Ethernet interface name (e.g., `enp39s0`) instead of `real`. Using `--interface real` may fail with `does not match an available interface` if CycloneDDS cannot auto-detect the correct interface inside Docker.

The deploy script will:
1. Kill any existing GR00T-WBC containers to prevent DDS conflicts.
2. Start a Docker container with host networking for DDS communication.
3. Launch the control loop inside a tmux session.
4. Display a **safety checklist** — read it carefully, type `Y` to confirm.

The control loop will:
1. Attempt to release the locomotion controller via `MotionSwitcherClient` (may show `send request error` — this is expected if the robot is already in debug mode via the remote controller).
2. Skip hand calibration (disabled with `--no-with_hands` to avoid hangs).
3. Load ONNX balance and walk policies.
4. Begin the main control loop (timing output only appears when the loop misses its target frequency).

> **Note:** The robot's arms will move to a default pose as soon as the control loop starts — this is the startup ramp and is expected. The `]` key activates the **balance policy** (legs), not the arm control.

### 3.4 Terminal 2 — Start the motion publisher

Open a new terminal on the host and attach to the same Docker container:

```bash
sudo docker exec -it gr00t_wbc-deploy-root /bin/bash
```

Inside the container, run the publisher (single line):

```bash
python gr00t_wbc/control/main/teleop/publish_upper_body_from_results.py --results resources/poses/PXL_20260114_214954286.pkl --loop --teleop-frequency 30 --hand-mode zero --speed 0.25 --initial-pose-seconds 10.0 --upper-body-only --smooth 3.0 --two-pass
```

You should see:

```
[info] applied Gaussian smoothing (sigma=3.0 frames)
[info] clamped N out-of-range joint values to 95% of URDF limits
==================================================
[PASS 1] Playing trajectory once — sim is recording collisions...
[PASS 1] Press ] in Terminal 1 to activate, wait 5s, press 9
==================================================
```

After pass 1 completes, the publisher automatically reads the collision log, fixes those frames, and starts pass 2 (looping). You do NOT need to restart or re-activate — the control loop stays running.

> **Start with `--speed 0.25` or lower.** On real hardware, motions that look fine in sim can generate dangerous torques. Quarter speed is a safe starting point. You can increase gradually once you confirm the robot is stable.

### 3.5 Activate the policy

Switch to **Terminal 1** (the tmux control pane — use Ctrl+b then arrow keys to navigate between tmux panes). Press keyboard keys in the **terminal**, not any viewer window.

1. Press `]` to activate the balance policy. You should see `Use policy action: True` printed.
2. Wait for the initial pose settle period (10 seconds). The robot's joints will slowly move to the starting pose.
3. Observe the robot carefully. The arms should begin replaying the video motion.

### 3.6 Lower the robot (when ready)

Once the balance policy is active and the robot is holding a stable pose in the harness:

1. **Have the safety operator ready** with the remote controller.
2. Slowly lower the suspension frame so the robot's feet touch the ground.
3. Gradually transfer weight from the harness to the robot's legs.
4. If the robot wobbles excessively, raise it back up and reduce `--speed` further.
5. Once standing stably, you can fully release the harness (but keep it within reach).

### 3.7 Switching to a different video

To replay a different video, stop the publisher in Terminal 2 (Ctrl+C) and start it again with a different `.pkl`:

```bash
python gr00t_wbc/control/main/teleop/publish_upper_body_from_results.py --results resources/poses/PXL_20260114_215356412.pkl --loop --teleop-frequency 30 --hand-mode zero --speed 0.25 --initial-pose-seconds 10.0 --upper-body-only --smooth 3.0 --two-pass
```

The control loop in Terminal 1 does not need to be restarted.

---

## 4. Safety Procedures

### Emergency Stop Options

There are three ways to stop the robot immediately. The safety operator should know all three:

| Method | How | Effect | When to Use |
|--------|-----|--------|-------------|
| **Remote: L2 + B** | Press on Unitree remote controller | Damping mode — all joints gently resist motion, robot slows to a stop | Preferred first response. Robot stays upright if possible. |
| **Remote: L2 + Y** | Press on Unitree remote controller | Zero torque — all motors instantly turn off | Robot is in danger of damaging itself or surroundings. Robot will collapse. |
| **Keyboard: backtick (`` ` ``)** | Press in Terminal 1 | Kills the tmux session running the control loop | Software-level stop from the workstation. |

**Order of preference:**
1. **L2 + B** (damping) — try this first. The robot decelerates gracefully.
2. **L2 + Y** (zero torque) — if damping is not enough or the robot is moving dangerously. The robot will fall, so make sure the area is clear.
3. **Backtick** — use this if the remote controller is not responding, or as a supplement to the remote e-stop.

### Safety Roles

- **Operator** (at the workstation): runs commands, monitors terminal output, can use keyboard e-stop.
- **Safety observer** (holding remote controller): watches the robot, ready to press L2+B or L2+Y at any moment. Does not need to interact with the workstation.

**Never run the hardware pipeline alone.** Always have a safety observer present with the remote controller.

### Joint Safety Monitor

The GR00T-WBC control loop includes a `JointSafetyMonitor` that continuously checks joint velocities:

| Joint Group | Velocity Limit |
|-------------|---------------|
| Arm joints | 6.0 rad/s |
| Hand joints | 50.0 rad/s |

If any joint exceeds its velocity limit, the control loop calls `sys.exit(1)` immediately. This is intentional — on real hardware, velocity violations are not warnings, they are hard stops. If this happens:

1. The robot enters a passive state (no more commands sent).
2. Use **L2 + B** on the remote to ensure damping mode.
3. Investigate which joint exceeded the limit before restarting.

### What To Do If the Robot Falls

1. Press **L2 + Y** (zero torque) immediately to prevent motor damage from the robot fighting against the ground.
2. Kill the control loop (backtick or Ctrl+C).
3. Physically inspect the robot for damage before attempting to restart.
4. If restarting: power cycle the robot, re-enter debug mode, and begin the deployment procedure from Section 3.2.

---

## 5. Known Risks

### Balance Policy Limitations

The balance policy (ONNX checkpoint shipped with GR00T-WBC) was trained in simulation and has known limitations:

- **Leg tremor on bent knees:** The policy oscillates when trying to maintain a crouched posture. This is more pronounced on real hardware due to motor backlash.
- **No dynamic walking guarantee:** The policy is primarily trained for standing balance. Walking commands (`w`/`s`/`a`/`d` keys) may work in sim but are riskier on real hardware.
- **Upper body speed sensitivity:** Fast arm motions shift the center of mass beyond what the balance policy can compensate for. This is why `--speed 0.25` is critical.
- **No newer checkpoint available:** NVIDIA has not released an improved balance checkpoint, and the Decoupled WBC training code is not publicly available.

### Sim-to-Real Gaps

| Gap | Impact | Mitigation |
|-----|--------|------------|
| Waist pitch KD | Automatically reduced by 10x in `real` mode | Built into the code, no action needed |
| No odometry | Robot does not know its absolute position | Acceptable for upper-body teleoperation |
| Motor friction and backlash | Joints may not reach commanded positions precisely | Start with slow motions to verify tracking |
| Floor surface | Sim assumes flat, high-friction ground | Use flat, non-slip flooring. Avoid carpet or polished surfaces. |
| Cable drag | Ethernet cable exerts force on the robot | Route cable overhead or use enough slack to avoid pulling |

### Speed Limits

| Parameter | Recommended Value | Why |
|-----------|------------------|-----|
| `--speed` (publisher) | 0.25 (start here) | Quarter speed keeps torques within the balance policy's stability envelope |
| `upper_body_joint_speed` (configs.py) | 5.0 rad/s (default) | Must stay below ARM_VELOCITY_LIMIT (6.0 rad/s) to avoid hard shutdown. Tunable per-video via `--upper-body-joint-speed` CLI arg on the control loop |
| `--smooth` (publisher) | 3.0 (recommended) | Gaussian smoothing of pose data. Removes jitter from noisy PromptHMR tracking. Higher = smoother but less faithful. 0 = disabled |
| `--two-pass` (publisher) | Recommended for hardware | Two-pass collision removal. Pass 1 plays the trajectory once while the sim logs all self-collisions. Pass 2 fixes those frames by interpolating through them smoothly, then loops. Catches collisions caused by the balance policy's leg motion that static checks miss |
| `--collision-free` (publisher) | Alternative to --two-pass | Static MuJoCo collision check on all frames before playback. Faster but less accurate — doesn't account for balance policy leg motion. Use `--two-pass` when possible |

**Gradually increase speed only after confirming stability** at the current speed. Suggested progression: 0.25 -> 0.35 -> 0.5. Do not exceed 0.5 on first deployment.

### Safety Monitors

| Check | Threshold | Behavior |
|-------|-----------|----------|
| Arm joint velocity | 6.0 rad/s (NVIDIA) | Hard exit on real hardware, warning in sim |
| Hand joint velocity | 50.0 rad/s (NVIDIA) | Hard exit on real hardware, warning in sim |
| Arm joint position | 95% of URDF range | Hard exit on real hardware (5% margin before mechanical stop) |
| Shoulder roll position | ±0.75 rad (self-collision-safe) | Publisher clamps via `SELF_COLLISION_SAFE_LIMITS` — prevents arm-torso contact |
| Self-collision | MuJoCo mesh collision geoms | Warning in sim (logged to `/tmp/gr00t_collision_log.jsonl`). Use `--two-pass` to auto-fix |

---

## 6. Troubleshooting

### Network

| Problem | Solution |
|---------|----------|
| `ping 192.168.123.164` fails | Check cable, verify interface IP is `192.168.123.222/24`, wait for robot to boot (~1 min) |
| DDS topics not discovered | Ensure Docker is running with `--deploy` flag (host networking). Check that no firewall blocks UDP on the `192.168.123.0/24` subnet. |
| SSH works but control loop cannot connect | The control loop auto-detects the interface with a `192.168.123.*` IP. If you have multiple interfaces in that subnet, disconnect the extras. |

### Robot Startup

| Problem | Solution |
|---------|----------|
| Robot does not power on | Verify battery is charged (LED indicators on the robot). Try the power sequence again: short press, then 2+ second long press. |
| L2+R2 does not release locomotion controller | Make sure you pressed L2+B (damping) first. The remote controller must be paired with the robot (it pairs automatically on boot). |
| Robot jerks on startup | This can happen if debug mode was not entered cleanly. Power cycle and repeat Section 2. |

### Control Loop

| Problem | Solution |
|---------|----------|
| `--interface real` cannot find Ethernet interface | Use the explicit interface name instead (e.g., `--interface enp39s0`). Run `ip link show` on the host to find it. |
| `real: does not match an available interface` | Same as above — pass the actual interface name, not `real`. |
| Joint velocity violation (`sys.exit(1)`) | Reduce `--speed` in the publisher. Default `upper_body_joint_speed` is now 5.0 rad/s (below 6.0 limit). Add `--smooth 3.0` to filter noisy pose data. For per-video tuning, pass `--upper-body-joint-speed 4.0` to the control loop. |
| Shoulder roll position safety violation on startup | The robot's arms naturally rest at ~0 rad shoulder roll after entering debug mode, but the URDF lower bound is 0.19 rad. Combined with the 5% critical margin, the safety monitor triggers immediately. **Fix:** Widen the shoulder roll bounds in `gr00t_wbc/control/robot_model/supplemental_info/g1/g1_supplemental_info.py`: change `left_shoulder_roll_joint` lower bound from `0.19` to `-0.5` and `right_shoulder_roll_joint` upper bound from `-0.19` to `0.5`. This allows the natural rest position while still catching arms crossing the body. |
| Hand calibration hangs | Use `--no-with_hands` to skip hand calibration. The publisher uses `--hand-mode zero` so hands are not needed. Alternatively, wait up to 30 seconds or power cycle the robot's hands. |
| `[ClientStub] send request error` / `3102 None` | The `MotionSwitcherClient` cannot reach the robot's service from Docker. Enter debug mode via the physical remote (L2+B then L2+R2) before starting the control loop. |
| Control loop starts but robot does not move | 1. Verify the robot is in debug/develop mode (L2+B then L2+R2 on the remote). 2. Press `]` in Terminal 1 to activate the policy. 3. Verify the publisher is running in Terminal 2. |
| Docker image `gr00t_wbc-deploy-root` not found | Tag the cached image: `sudo docker tag gr00t_wbc-deploy-cache-root:latest gr00t_wbc-deploy-root:latest`. Or pull from remote: `./docker/run_docker.sh --install --root`. |

### General

| Problem | Solution |
|---------|----------|
| Robot falls when weight transferred from harness | Raise the robot back into the harness. Reduce `--speed`. Verify the balance policy is active (`Use policy action: True` in Terminal 1). |
| Motions look different from sim | Expected due to sim2real gaps. Real motors have friction, backlash, and compliance that the sim does not model. Reduce speed for closer tracking. |
| Battery low warning | Land the robot back in the harness, press L2+B (damping), and shut down gracefully. Do not continue operating on low battery — motor torques may become inconsistent. |

---

## 7. Quick Reference Card

Print this section and keep it near the robot during deployment.

```
EMERGENCY STOP
  Remote:  L2 + B  (damping — try first)
  Remote:  L2 + Y  (zero torque — robot will fall)
  Keyboard: `      (backtick — kills control loop)

STARTUP SEQUENCE
  1. Suspend robot in harness
  2. Power on (short press + long press)
  3. Wait ~1 minute
  4. L2 + B (damping mode)
  5. L2 + R2 (debug mode)
  6. Start control loop: --interface enp39s0
  7. Start publisher: --speed 0.25
  8. Press ] to activate policy
  9. Wait 10 seconds for initial pose
  10. Slowly lower harness

NETWORK
  Robot:       192.168.123.164
  Workstation: 192.168.123.222/24
  SSH:         unitree@192.168.123.164 (pw: 123)

VELOCITY LIMITS
  Arm joints:  6.0 rad/s (hard kill on real hardware)
  Hand joints: 50.0 rad/s (hard kill on real hardware)
  Position:    95% of URDF range (hard kill on real hardware)
  Shoulder roll: ±0.75 rad (self-collision-safe clamp)
  upper_body_joint_speed: 5.0 rad/s (InterpolationPolicy cap)
  Recommended: --speed 0.25 --smooth 3.0 --two-pass
```
