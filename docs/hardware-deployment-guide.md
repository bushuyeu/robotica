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

### 3.1 Prepare the retarget results

Same as in simulation — copy the retarget `.pkl` to the Docker-accessible location:

```bash
mkdir -p ~/Projects/GR00T-WholeBodyControl/resources/poses/
cp results/<video_name>/retarget_unitree_g1.pkl \
   ~/Projects/GR00T-WholeBodyControl/resources/poses/<video_name>.pkl
```

### 3.2 Terminal 1 — Start the control loop (hardware mode)

```bash
cd ~/Projects/robotica/GR00T-WholeBodyControl

# Start Docker with deploy flag for hardware access
./docker/run_docker.sh --deploy --root

# Inside the container:
python gr00t_wbc/control/main/teleop/run_g1_control_loop.py --interface real
```

The `--deploy` flag configures Docker with the network access needed for real hardware (host networking for DDS communication).

The control loop will:
1. Auto-detect the Ethernet interface with a `192.168.123.*` IP.
2. Establish DDS communication with the robot over `rt/lowcmd` and `rt/lowstate` topics.
3. Run hand calibration automatically.
4. Display a **safety checklist** — read it carefully and confirm before proceeding.
5. Begin a 2-second startup ramp for smooth joint initialization.

### 3.3 Terminal 2 — Start the motion publisher

Open a new terminal on the host:

```bash
docker exec -it gr00t_wbc-bash-root /bin/bash

# Inside the container:
python gr00t_wbc/control/main/teleop/publish_upper_body_from_results.py \
    --results resources/poses/<video_name>.pkl \
    --loop \
    --teleop-frequency 30 \
    --hand-mode zero \
    --speed 0.25 \
    --initial-pose-seconds 10.0 \
    --upper-body-only
```

> **Start with `--speed 0.25` or lower.** On real hardware, motions that look fine in sim can generate dangerous torques. Quarter speed is a safe starting point. You can increase gradually once you confirm the robot is stable.

### 3.4 Activate the policy

In **Terminal 1** (where the control loop is running):

1. Press `]` to activate the balance policy. You should see `Use policy action: True` printed.
2. Wait for the initial pose settle period (10 seconds). The robot's joints will slowly move to the starting pose.
3. Observe the robot carefully. The arms should begin replaying the video motion.

### 3.5 Lower the robot (when ready)

Once the balance policy is active and the robot is holding a stable pose in the harness:

1. **Have the safety operator ready** with the remote controller.
2. Slowly lower the suspension frame so the robot's feet touch the ground.
3. Gradually transfer weight from the harness to the robot's legs.
4. If the robot wobbles excessively, raise it back up and reduce `--speed` further.
5. Once standing stably, you can fully release the harness (but keep it within reach).

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
| `upper_body_joint_speed` (configs.py) | 100 rad/s | Default 1000 rad/s is far too aggressive — same fix as sim |

**Gradually increase speed only after confirming stability** at the current speed. Suggested progression: 0.25 -> 0.35 -> 0.5. Do not exceed 0.5 on first deployment.

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
| `--interface real` cannot find Ethernet interface | Verify your workstation has an interface with IP `192.168.123.222`. Run `ip addr` to check. |
| Joint velocity violation (`sys.exit(1)`) | Reduce `--speed` in the publisher. Check that `upper_body_joint_speed` is 100 (not 1000) in `configs.py`. |
| Hand calibration hangs | Wait up to 30 seconds. If it does not complete, power cycle the robot's hands (if independently powered) or restart the control loop. |
| Control loop starts but robot does not move | Press `]` in Terminal 1 to activate the policy. Verify the publisher is running in Terminal 2. |

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
  6. Start control loop: --interface real
  7. Start publisher: --speed 0.25
  8. Press ] to activate policy
  9. Wait 10 seconds for initial pose
  10. Slowly lower harness

NETWORK
  Robot:       192.168.123.164
  Workstation: 192.168.123.222/24
  SSH:         unitree@192.168.123.164 (pw: 123)

VELOCITY LIMITS
  Arm joints:  6.0 rad/s
  Hand joints: 50.0 rad/s
  Recommended --speed: 0.25
```
