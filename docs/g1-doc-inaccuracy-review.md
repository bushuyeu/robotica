# Inaccuracy Review: "Humanoid Robot Info for AI Lab People"

Cross-referenced against verified project knowledge (robotica memory, hardware-deployment-guide, gr00t-sim notes, and working configurations as of 2026-03-19). Items marked **(VERIFIED)** were confirmed by live testing on the robot.

---

## CRITICAL — Will cause hardware problems or failed connections

### 1. SSH IP Address: 192.168.123.161 vs 192.168.123.164
**Location:** Lines 389, 411, 463, 1188 (repeated in multiple sections)
**Document says:** `ssh unitree@192.168.123.161` / `ping 192.168.123.161`
**Correct:** `ssh unitree@192.168.123.164` — The `.161` address is the **locomotion controller**, NOT the onboard Linux computer (Orin NX). SSH goes to `.164`.
**Impact:** Students will fail to connect and waste time debugging networking.
**Note:** Line 697 and the "SSH into Jetson" section (line 673+) correctly use `.164`. The document contradicts itself.
**(VERIFIED 2026-03-19):** SSH to `.164` succeeds (Ubuntu 20.04, Tegra aarch64, Orin NX). SSH to `.161` returns "Connection refused" — no SSH daemon running on the locomotion controller.

### 2. Laptop IP suggestion: 192.168.123.99 vs 192.168.123.222
**Location:** Line 386
**Document says:** "Set your Laptop IP to `192.168.123.99`"
**Correct:** The verified working workstation IP is `192.168.123.222/24`. While any IP on the `/24` subnet technically works, `.222` is what is configured and tested throughout the rest of the document (lines 660, 688) and all project tooling. Using `.99` is not wrong per se, but inconsistent with the rest of the document and all project configs.

### 3. Missing critical step: L2+B before L2+R2
**Location:** Lines 397-398, 464
**Document says:** "Press L2 + R2 ... This typically puts the robot into Debug Mode"
**Correct:** You must first press **L2+B** (damping mode), THEN **L2+R2** (debug/develop mode). Skipping L2+B means the robot is not in damping mode first, which is an unsafe transition. The robot should go through damping before releasing the locomotion controller.

### 4. Ping target in flight checklist
**Location:** Line 463
**Document says:** "Ping Robot: `ping 192.168.123.161` returns success"
**Correct:** Should be `ping 192.168.123.164` (the onboard Linux computer). Pinging `.161` tests the locomotion controller, not the computer you SSH into and deploy code on.

### 5. Missing `net-tools` requirement
**Location:** Not mentioned anywhere in the document
**Issue:** CycloneDDS requires the `ifconfig` binary (from `net-tools` package) to detect the network interface for the `rt/lowcmd` topic. Without it, the control loop starts but the robot will not move. `ip addr` is NOT a substitute. This is a known gotcha that has burned hours of debugging.
**Fix:** Add `sudo apt install net-tools` to prerequisites.

---

## SIGNIFICANT — Misleading or incomplete, could cause confusion

### 6. "Robot should go limp" after L2+R2
**Location:** Line 398
**Document says:** "The robot should go limp or hold position loosely, not trying to balance itself actively."
**Clarification:** After L2+B (damping mode), joints offer gentle resistance — the robot does NOT go "limp." After L2+R2 (debug mode), the built-in locomotion controller releases and SDK commands are accepted. The wording "go limp" could be confused with L2+Y (zero torque), which actually makes the robot collapse. This distinction matters for safety.

### 7. Emergency stop procedures are incomplete
**Location:** Not documented as a dedicated section
**Issue:** The document mentions L2+R2 for debug mode but never documents the three emergency stop methods:
- **L2+B** — Damping mode (primary e-stop, graceful)
- **L2+Y** — Zero torque (secondary, robot collapses)
- **Backtick (`)** — Keyboard e-stop in terminal (kills tmux control session)

This is safety-critical information that should be prominently displayed.

### 8. "Slowly lower the tether" without balance policy context
**Location:** Lines 426-429
**Document says:** Lower the tether, robot detects contact and starts stepping.
**Missing context:** For GR00T-WBC workflow, the balance policy must be activated FIRST (`]` key in terminal), and the elastic band released (`9` key) before lowering. The document describes this generically as if the RL policy handles everything automatically, which is only true for unitree_rl_gym policies, not GR00T-WBC.

### 9. Joint safety limits not documented
**Location:** Not mentioned
**Issue:** The document has no mention of the JointSafetyMonitor limits that are critical on real hardware:
- Arm joints: 6.0 rad/s max velocity
- Hand joints: 50.0 rad/s max velocity
- Violation = **hard exit** (`sys.exit(1)`) on real hardware
- `upper_body_joint_speed` must be 100 rad/s (not default 1000)
- `--speed 0.25` should be starting speed for publisher

### 10. No mention of two-person safety requirement
**Location:** Safety sections throughout
**Issue:** The document never states that hardware operation requires TWO people:
- **Operator** at workstation (runs commands, keyboard e-stop)
- **Safety observer** holding remote controller (L2+B / L2+Y ready)

The MOU section (line 203) mentions gantry mandate but not the two-person rule.

### 11. Generic IP range in "Minimal G1 Ethernet Steps"
**Location:** Lines 480-481
**Document says:** "often `192.168.123.xx` range" and "e.g., `192.168.123.15`" and "ping `192.168.123.10`"
**Correct:** The G1's onboard computer is always `192.168.123.164`. The workstation should be `192.168.123.222/24`. Using vague examples like `.15` or `.10` adds confusion when exact IPs are known.

---

## MODERATE — Outdated, inconsistent, or could be clearer

### 12. GR00T section uses different paths than verified setup
**Location:** Lines 1253-1275
**Document says:** `/home/esports/Documents/unitree/Isaac-GR00T` and references `uv run python`
**Correct setup:** The verified GR00T-WBC workflow uses Docker (`gr00t_wbc-deploy-root:latest`) with the standalone repo at `~/Projects/GR00T-WholeBodyControl`. The `Isaac-GR00T` path and `uv run` approach appears to be a different (newer GR00T N1.6) workflow that may be valid but is not the tested pipeline.

### 13. `unitree_rl_gym` install uses raw pip
**Location:** Line 327
**Document says:** `pip install -e .`
**Project convention:** All Python operations should use `uv`, not raw `pip`. This applies to lines 327, 1147, and similar.

### 14. `scp` to robot for deployment
**Location:** Line 411
**Document says:** `scp logs/g1_walk/model_2000.pt unitree@192.168.123.161:~/unitree_rl_gym/deploy/`
**Issues:** (a) Wrong IP — should be `.164` not `.161`. (b) For GR00T-WBC workflow, `.pkl` files are copied to `~/Projects/GR00T-WholeBodyControl/resources/poses/` via `just groot-copy <video>`, not via scp to the robot.

### 15. Docker display setting
**Location:** Not mentioned in Isaac Sim Docker sections
**Issue:** This workstation uses `DISPLAY=:2`, not the common `:0`. The document's Docker commands (lines 1306-1318) use `$DISPLAY` which would inherit the correct value, but this is worth noting for troubleshooting since `:0` is the common assumption and will fail on this workstation.

### 16. Inconsistent hand model references
**Location:** Lines 1287-1298, 1629-1661
**Issue:** The document references both "standard 3-finger hands" and "Inspire RH56DFTP" (dexterous 5-finger) without clearly stating which configuration the lab's G1 actually has. The G1 EDU appears to have the Inspire hands (29 DOF), but the GR00T-WBC pipeline currently runs with `--hand-mode zero` and `--no-with_hands`, meaning hands are not actively controlled.

### 17. WiFi deployment section is aspirational
**Location:** Lines 1225-1231
**Document says:** Configure WiFi for untethered operation.
**Reality:** All verified deployments use wired Ethernet. WiFi introduces latency and jitter that can destabilize low-level control. This section should be clearly marked as experimental/future.

---

## MINOR — Typos and formatting

### 18. Typos
- Line 16: "G1 Open Source Datase**t**" — closing `t` is outside the link
- Line 17: "Wait Hardware" — should be "Waist Hardware" (waist fastener)
- Line 107: "fake hand documentaoin" — should be "documentation"
- Line 241: "moel_0.pt" — should be "model_0.pt"
- Line 927: "debugging" phase note has garbled numbers "6666"
- Lines 933-946: Multiple instances of repeated digits ("8888", "9999", "10101010", etc.) — appears to be footnote reference rendering artifacts

### 19. Google Search wrapper links
**Location:** Lines 15-16, 26, 37-38, 45, 450
**Issue:** Several links are wrapped in `https://www.google.com/search?q=...` instead of being direct URLs. These redirect through Google Search rather than going to the actual resource.

---

## Summary

| Severity | Count | Key Theme |
|----------|-------|-----------|
| CRITICAL | 5 | Wrong SSH IP (repeated 4x), missing safety step, missing `net-tools` |
| SIGNIFICANT | 6 | Incomplete safety docs, misleading e-stop behavior, missing velocity limits |
| MODERATE | 6 | Path inconsistencies, outdated tooling, unclear hardware config |
| MINOR | 2 | Typos, broken link formatting |

**Top 3 fixes to prioritize:**
1. Change all `192.168.123.161` SSH/ping references to `192.168.123.164`
2. Add complete emergency stop procedures (L2+B, L2+Y, backtick) prominently
3. Add `net-tools` requirement and two-person safety rule
