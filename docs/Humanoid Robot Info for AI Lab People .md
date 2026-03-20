# **Quick Ref and Links**

🤖 Unitree G1 (Humanoid)

### **Critical Technical Notes**

* **Stuttering Issue:** When running deploy\_real\_g1\_config (motion.pt), stuttering is often caused by **DDS (Data Distribution Service) configuration**.  
* **Fix:** Check network interface settings and ensure the CYCLONEDDS\_URI is correctly pointing to the robot's network. Refer to [Issue \#43](https://github.com/unitreerobotics/unitree_sdk2_python/issues/43).  
* **Deployment:** Robots can be connected via laptop and set to **Ready Mode** before running deployment scripts.

### **Documentation & SDK**

* **Manuals:** [User Manual](https://marketing.unitree.com/article/en/G1/User_Manual.html) | [Developer Support](https://support.unitree.com/home/en/G1_developer)  
* **SDK Quick Start:** [Unitree SDK2 Guide](https://support.unitree.com/home/en/G1_developer/quick_development)  
* **Hands:** [Standard Prosthetic](https://support.unitree.com/home/en/G1_developer/End_Prosthetic_Hand) | [Inspire Dexterous Hand](https://support.unitree.com/home/en/G1_developer/Flagship_Version_C_End_INSPIRE_Dexterous_Hand)  
* **Data:** [G1 Open Source Dataset](https://github.com/unitreerobotics/unitree_g1_dataset)
* **Waist Hardware:** [https://support.unitree.com/home/en/G1\_developer/waist\_fastener](https://support.unitree.com/home/en/G1_developer/waist_fastener)  
* Open Source Datasets: [https://www.unitree.com/opensource](https://www.unitree.com/opensource)  
* [https://github.com/unitreerobotics](https://github.com/unitreerobotics)  
* 

### **Research & Custom Projects**

* **Walking on All 4s:** [G1 Crawl Repo](https://github.com/jloganolson/g1_crawl) (Includes 3D printed head/arm parts).  
* **Skills:** [G1 Spin-Kick Example (MuJoCo)](https://github.com/mujocolab/g1_spinkick_example) | [Kung-Fu Workflow](https://kungfu-bot.github.io/)  
* **VLA Models:** [NaVILA Vision-Language-Action for G1](https://github.com/unitreerobotics/NaVILA)

[https://gmargo11.github.io/softmimic/](https://gmargo11.github.io/softmimic/) [https://www.instagram.com/p/DQsFiHlESNf/](https://www.instagram.com/p/DQsFiHlESNf/)

MIT \- A way of doing soft movement so the bot doesn't hit or break anything. 

---

## **🐕 Unitree Go2 (Quadruped)**

* **Manuals:** [User Manual](https://marketing.unitree.com/article/en/Go2/User_Manual.html) | [Developer Support](https://support.unitree.com/home/en/developer)  
* **Hardware Deep Dive:** [Go2 Teardown Video](https://www.youtube.com/watch?v=your_video_link)
* **Setup:** [Unboxing & Connection Video](https://www.youtube.com/watch?v=your_video_link)

---

## **🏗️ Isaac Sim & Simulation**

* **Introduction:** [Isaac Lab Welcome](https://isaac-sim.github.io/IsaacLab/)  
* **Tutorials:** [Legged Robotics RL Series](https://www.youtube.com/playlist?list=PL4OW_H79Z91uS891q6I35P0uW0A1iU6gU) | [Deploying Policies](https://github.com/isaac-sim/IsaacLab)  
* **Community:** [Isaac Lab Basics Discord](https://discord.com/invite/CqV7NFHGb5)

---

## **🌐 Community & Support**

| Resource | Purpose | Link |
| :---- | :---- | :---- |
| **G1 Hackers** | Upgrading consumer units / hacking | [Join Discord](https://discord.gg/WE82Xd2j) |
| **LycheeAI** | General AI/Robotics discussions | [Join Discord](https://discord.gg/MfZFB8tQ) |
| **General Q\&A** | Developer troubleshooting | [Join Discord](https://discord.gg/HEXNMCNhEh) |
| **Official GitHub** | Unitree Robotics Organization | [Visit GitHub](https://github.com/unitreerobotics) |

Unitree contacts:

夏子莲 \<sales\_xzl@unitree.com\>  
王兴兴 \<laikago@unitree.cc\>,  
陈璐 \<sales\_cl@unitree.com\>,  
杨亚 \<sales\_yy@unitree.com\>

Custom HawAII repos (contact [igormolybog@gmail.com](mailto:igormolybog@gmail.com) 7272763067 to be added to the github org):  
[https://github.com/haw-ai-i/unitree-pot/tree/ryan](https://github.com/haw-ai-i/unitree-pot/tree/ryan)

**Other Research to review:  Dec:**  
One thing to be careful of when we run our own policy. When he uploaded his own, his arm ripped itself off. But I think he goes over the fix. [https://youtu.be/FGnAeUXRZ4E?t=235](https://youtu.be/FGnAeUXRZ4E?t=235)

[https://discord.com/invite/sentdex](https://discord.com/invite/sentdex)   
The guy who's gone through most of this. He might have example code to get to ready mode without controller

[Training a Unitree G1 to Walk w/ Reinforcement Learning](https://www.youtube.com/watch?v=FGnAeUXRZ4E) Training a Unitree G1 to Walk w/ Reinforcement LearningUsing mjlab and PPO to train the Unitree G1 humanoid to walk inside and outside

[https://x.com/kevin\_zakka/status/1998914931396395321](https://x.com/kevin_zakka/status/1998914931396395321)  
Premade MJlab projects

People to reach out to who have done this:  
[https://x.com/ZhiSu22](https://x.com/ZhiSu22)  
[**https://roboticseabass.com/2025/12/27/2025-in-review-developer-experience/**](https://roboticseabass.com/2025/12/27/2025-in-review-developer-experience/)  
[**https://x.com/Berkeley\_AI**](https://x.com/Berkeley_AI)  
[https://x.com/kevin\_zakka](https://x.com/kevin_zakka)  
[https://x.com/Boyiliee](https://x.com/Boyiliee)

# 

# **RAW LINKS BELOW:**

Discord servers for questions: [https://discord.gg/HEXNMCNhEh](https://discord.gg/HEXNMCNhEh)

LycheeAI discord [https://discord.gg/MfZFB8tQ](https://discord.gg/MfZFB8tQ)

[https://github.com/unitreerobotics](https://github.com/unitreerobotics)

12/22 we can connect from laptop and put it in ready mode. But when we try to run deploy real g1 config which runs [motion.pt](http://motion.pt) we get stuttering. (Notes here on why stutter happens: [https://github.com/unitreerobotics/unitree\_sdk2\_python/issues/43](https://github.com/unitreerobotics/unitree_sdk2_python/issues/43))

Quick References 

G1 Humanoid:   
[https://marketing.unitree.com/article/en/G1/User\_Manual.html](https://marketing.unitree.com/article/en/G1/User_Manual.html)  
G1 SDK: [https://support.unitree.com/home/en/G1\_developer](https://support.unitree.com/home/en/G1_developer)  
Video on setup: [Unitree G1 Basic Unboxing | How to Power On, Connect to Controller/Phone & Start Controlling](https://www.youtube.com/watch?v=1OpngwB6gWM&list=WL&index=10)  
Setup and Calibration: [How to Calibrate G1 Humanoid Robot from Unitree](https://www.youtube.com/watch?v=V-Zaovo5pB4)

G1 fake hand documentation: [G1- End Prosthetic Hand](https://www.unitree.com/images/G1-End%20Prosthetic%20Hand%20Disassembly%20and%20Assembly%20Guide%20Manual.pdf)

G1 fancy hand [G1- Flagship Version C End INSPIRE Dexterous Hand](https://www.unitree.com/images/G1-Flagship%20Version%20C%20End%20Dexterous%20Hand%20Disassembly%20and%20Assembly%20Guide%20Manual.pdf)

Go2 Dog:  
[https://marketing.unitree.com/article/en/Go2/User\_Manual.html](https://marketing.unitree.com/article/en/Go2/User_Manual.html)  
[https://support.unitree.com/home/en/developer](https://support.unitree.com/home/en/developer)  
Video on setup: [Unitree Go2 Pro Unboxing | How to Get Your Robot Ready to Go\!](https://www.youtube.com/watch?v=-66f-IwI0wQ)  
Quick video of Dog prebuilt features: [I tried EVERY function of this robot dog](https://www.youtube.com/watch?v=TZYxgwsVQt0)  
Full unboxing and setup: [1, Unboxing Unitree Go2 Robot](https://www.youtube.com/watch?v=m6-n51A3dao&list=PLJaMZYYjldgOS7IEZODioMkb_fMWphRoJ)

Additional things: open source dataset: [Unitree G1 Open Source Dataset](https://www.youtube.com/watch?v=OTWHXTu09wE)

A tutorial Isaac Sim [Isaac Lab Legged Robotics Reinforcement Learning-1 Introduction](https://www.youtube.com/watch?v=wCuAAAcWBTM)  
[Welcome to Isaac Lab\!](https://isaac-sim.github.io/IsaacLab/main/index.html)

Unitree sdk2: [https://support.unitree.com/home/en/G1\_developer/quick\_development](https://support.unitree.com/home/en/G1_developer/quick_development)

VLA that has been tried on Unitree G1: [NaVILA: Legged Robot Vision-Language-Action Model for Navigation](https://navila-bot.github.io/)

12/21 videos from gabe:

Video of a guy who went through it all: [I Tried To Build a Robot Like Boston Dynamics With Isaac Sim](https://www.youtube.com/watch?v=YDzHL2JSCHc)

Isaac Lab Tutorial 1: Full series.  [Creating an Empty Scene - Isaac Lab Tutorial 1 (Basics)](https://www.youtube.com/watch?v=sL1wCfp9tRU)  and his discord [https://discord.com/invite/CqV7NFHGb5](https://discord.com/invite/CqV7NFHGb5)

Breakdown of G2 for hardware info after. [Tearing Down the Unitree Go2: A Robotics Expert's Deep Dive](https://www.youtube.com/watch?v=YjVbW6Fc11Y)

How to deploy a policy in isaac sim [Deploying Policies in Isaac Sim](https://docs.isaacsim.omniverse.nvidia.com/5.1.0/isaac_lab_tutorials/tutorial_policy_deployment.html)

Humanoid walking on all 4s hunting. That's me\! i'll clean up the repo this week (its public in its raw form here [https://github.com/jloganolson/g1\_crawl](https://github.com/jloganolson/g1_crawl)

* [Head parts (requires heat-set inserts for screws)](https://cad.onshape.com/documents/51f2b1c723880a644b5e4295/w/26b9ae2d16dd6818ee2cba50/e/2c03d03c2d68d17d48cc747c?renderMode=0&uiState=690ba6558c75f7c496f162c5)  
* [Custom arms (requires a squash ball)](https://cad.onshape.com/documents/be995b1470263c9f303ec0a3/w/a8114830271f7d8f2d8df84b/e/bdf2f54b49628d7c3c8cd944?renderMode=0&uiState=690ba6ab9ccb00f927e7e3db)  
* Corresponding 3MF print files live in 3d-printed-parts/.  
* [https://x.com/jloganolson/status/1969127016105402800](https://x.com/jloganolson/status/1969127016105402800)

Github examples [GitHub \- mujocolab/g1\_spinkick\_example: Train a Unitree G1 humanoid to perform a double spin kick using mjlab](https://github.com/mujocolab/g1_spinkick_example)

Discord for g1 hackers: [https://discord.gg/WE82Xd2j](https://discord.gg/WE82Xd2j) Supposedly you might be able to get a cheap consumer one and add your own upgrades. 

[https://kungfu-bot.github.io/](https://kungfu-bot.github.io/) workflow for video to kung fu that a group did. 

Unitree G1 Security Vulnerability  [https://www.youtube.com/watch?v=Ah0-l0HZwLA](https://www.youtube.com/watch?v=Ah0-l0HZwLA)

As of the latest credible information from **late September 2025**, Unitree has officially addressed these specific vulnerabilities:

* **Official Response:** On September 29, 2025, Unitree released a statement confirming they were aware of the security flaws (specifically the BLE and network issues). They stated they had **"completed the majority of the fixes"** and that a firmware update was **"imminent"** and would be rolled out to users in the "near future."  
* **The Fix:** You need to check for a firmware update released **after September 29, 2025**.  
  * The vulnerability affects firmware versions up to those released around **September 20, 2025**.  
  * If your robot is running firmware from before October 2025, it is **still vulnerable**.

### **Summary of the Issue in the Video**

* **The Bug (UniPwn):** Researchers found that Unitree robots use a hardcoded encryption key (the same key for every robot sold).  
* **The Exploit:** An attacker within Bluetooth range can simply send a specific command (using that known key) to inject root commands. This could allow them to spy on the robot's camera/microphone, move the robot, or turn it into a "zombie" that infects other nearby Unitree robots.

# **MOU**

# **MEMORANDUM OF UNDERSTANDING (MOU)**

## **Collaborative Robotics Research Partnership**

**Date:** January 15, 2026

**Location:** 'Iolani School AI Lab, Honolulu, HI

### **1\. PARTIES**

This Memorandum of Understanding (the "Agreement") is entered into by and between:

* **'Iolani School:** Represented by Gabriel Yanagihara (Director of Emerging Technology) and Kim Tsiang (AI/ML Teacher).  
* **HawAII Guest Research Team (UH Mānoa):** Igor Molybog, Anton Nikolaev, and Yosub Shin, Yujin Chen, Brian Shu, Pavel Bushueu (collectively, the "Guest Researchers").

  ### **2\. PURPOSE & PROJECT SCOPE**

The parties intend to collaborate on a non-commercial basis to develop machine learning (ML) workflows, simulation-to-real (Sim2Real) environments, and knowledge bases for the Unitree G1 Humanoid and Go2 Quadruped robotic platforms.

**Core Mission:** All parties acknowledge that the primary goal of this collaboration is to provide educational opportunities and advanced technical experiences for 'Iolani students. The secondary benefit is the development of expertise and research outcomes for the Guest Researchers alongside these students.

### **3\. INTELLECTUAL PROPERTY, USAGE & REPOSITORY**

* **Non-Commercial Collaboration:** This partnership is strictly for research and educational purposes.  
* **Mutual Access:** Both parties retain full permission and irrevocable access to use, modify, and publish any code, documentation, datasets, or workflows generated during this collaboration.  
* **GitHub & Documentation Policy:** To ensure the longevity of the 'Iolani AI/ML program, Guest Researchers agree to push all code and work-in-progress to a shared 'Iolani GitHub repository at every project milestone.  
* **Ongoing Access:** Research inspired by this lab space shall remain accessible to 'Iolani students to further support their academic growth.

  ### **4\. ASSUMPTION OF RISK & INDEMNIFICATION**

* **Acknowledgment of Emerging Field:** All parties acknowledge that humanoid robotics and vision-language-action (VLA) models are new and emerging fields. There is no guarantee or promise of successful working outcomes or specific performance.  
* **Nature of Equipment:** All parties acknowledge that the Unitree G1 and Go2 are **industrial-grade equipment**, not toys. They possess high-torque motors and high-voltage components capable of significant force.  
* **Risk of Injury:** Working in close proximity to robotics involves inherent risks, including but not limited to mechanical failure, erratic movement, and electrical hazards.  
* **Release of Liability:** The Guest Researchers hereby acknowledge these risks and agree to hold 'Iolani School, its employees, and administrators harmless. Guest Researchers will not hold 'Iolani School liable for any injury, illness, property damage, or death occurring on 'Iolani School premises related to this research.

  ### **5\. HARDWARE OPERATIONAL POLICY**

* **G1 Gantry Mandate:** The Unitree G1 **must always** be secured to a gantry or mounted support when running any software, policy, or movement not handled natively or pre-approved by Gabriel Yanagihara.  
* **Off-Gantry Protocol:** If the G1 is operated off-gantry for approved final testing, it must be placed on a padded EVA floor with physical stanchions (barriers) separating the robot from all personnel and students.  
* **Go2 Padded Floor Policy:** The Go2 quadruped must be tested on padded ground whenever new systems or experimental control loops are deployed.  
* **Maintenance & Event Log:** Gabriel Yanagihara will maintain an official log for broken parts, hardware issues, and event tracking. Guest Researchers are required to submit entries to this log for any incidents or technical failures encountered during their sessions.

  ### **6\. MENTORSHIP & ROLES**

* **Student Projects:** Each Guest Researcher will mentor one (1) student ML/AI project or independent research project per semester.  
* **Minimum Viable Interaction:** Mentorship is defined as a one-semester commitment, requiring a minimum of a one-hour weekly Zoom call or in-person session to ensure manageable time requirements for the UH team.  
* **Communication Policy:** To align with school policy and documentation requirements, **all** communications with students must include (CC) or involve Gabriel Yanagihara or Kim Tsiang.

  ### **7\. CONFLICT RESOLUTION**

In the event of a disagreement or conflict regarding research goals, hardware usage, or mentorship roles, the parties agree to seek mediation through 'Iolani School Administration and designated advisors from UH Mānoa who are senior to the individuals involved in this MOU.

### **8\. DATA PRIVACY & IT POLICY**

* **Student Privacy:** No student biometric data, images, or identifying information may be published, transmitted, or included in datasets without explicit written approval from 'Iolani School Administration.  
* **Infrastructure:** 'Iolani School will provide computers and internet access. All network usage must comply with 'Iolani School IT and security policies.

**Gabriel Yanagihara** Director of Emerging Technology, 'Iolani School

**UH Mānoa Lead Researcher** On behalf of the Guest Research Team

# **unitree\_rl Setup environment**

\# prerequisites on Ubuntu
sudo apt-get update
sudo apt-get install \-y build-essential net-tools
\# net-tools provides `ifconfig`, required by CycloneDDS to detect the network interface.
\# Without it, the control loop starts but the robot will not move.

\# Install unitree rl  
\# https://github.com/YosubShin/unitree\_rl\_gym/blob/main/doc/setup\_en.md  
\# Follow steps in the above setup documentation

\# Test setup  
cd \~/unitree\_rl\_gym/legged\_gym  
python scripts/play.py \--task=g1 \--run=flat

\# First initiate the training so it creates necessary folder structure as well as initial weights (model\_0.pt)  
python scripts/train.py \--task=g1  
\# This should open up the simulator and start training.

\# You don’t need to finish training. You can ctrl-c to exit.

\# Download pre-trained checkpoint from [here](https://drive.google.com/file/d/1kF_htij68bmXVPT3s2QFHYTM8-o9boYX/view?usp=sharing) and paste next to the initial model checkpoint (logs/g1/\<timestamped project name\>/)   
\# Running untrained model on sim  
python legged\_gym/scripts/play.py \--task=g1 \--checkpoint=0

\# Running trained model on sim  
python legged\_gym/scripts/play.py \--task=g1 \--checkpoint=10000

\# Reward function can be updated:

* Legged\_robot.py: Base LeggedRobot class and its rewards are defined here.  
* g1\_env.py: g1 humanoid specific rewards  
* g1\_config.py: Update weights of each reward. Setting the weight to 0 will disable that reward

Example (in g1\_config.py)

* tracking\_lin\_vel=1.0, tracking\_ang\_vel \= 0.5: rewards the robot when it moves with desired linear and angular velocity

\# Run on real robot  
\# Follow instructions [here]() to setup network to communicate with the robot

\# Update g1.yaml to point to the desired policy .pt file.  
python deploy/deploy\_real/deploy\_real.py enp7s0 g1.yaml 

# **Sim2Real with Unitree G1**

# **Course Module: Sim2Real with Unitree G1**

Goal: Train a neural network to walk in a physics simulation and deploy it onto physical hardware.  
Prerequisites: Python basics, Linux (Ubuntu) basics.

## ---

**Phase 0: The Mental Model (Theory)**

Before touching any code, students must understand the **Sim2Real Loop**.

### **1\. The Big Picture**

We cannot train on the real robot because:

1. **It breaks:** A robot falling 10,000 times destroys motors.  
2. **It's slow:** Real time is 1x. Simulation time can be 10,000x.

Instead, we use a workflow called **Sim2Real**:

1. **Simulate:** Create a "video game" version of the robot (Isaac Sim).  
2. **Train:** Use Reinforcement Learning (RL) to let the robot figure out how to walk by trial and error in the game.  
3. **Transfer:** Copy the "Brain" (Neural Network weights) to the real robot.  
4. **Deploy:** Run the brain on the real hardware.

### **2\. Vocabulary Cheat Sheet (CS/ML Terms)**

| Term | Definition | Context |
| :---- | :---- | :---- |
| **Policy ($\\pi$)** | The "Brain." A function taking sensor inputs and outputting motor targets. | *This is what we train.* |
| **Observation Space** | What the robot sees/feels. (Joint angles, IMU orientation). | *Input to the Policy.* |
| **Action Space** | What the robot controls. (Target joint positions). | *Output of the Policy.* |
| **PPO** | *Proximal Policy Optimization.* The specific RL algorithm used. It's the industry standard for walking. | *The learning algorithm.* |
| **Domain Randomization** | Deliberately making the simulation "messy" (random friction, random pushes) so the robot learns to be robust. | *Crucial for Sim2Real.* |
| **Zero-Shot** | Running the sim policy on the real robot without any extra training in the real world. | *The ultimate goal.* |

## ---

**Phase 1: The "Virtual Lab" (Simulation Setup)**

**Hardware Required:** PC with Ubuntu 20.04/22.04 and NVIDIA RTX GPU (3070 or better recommended).

### **Step 1: Install the Environment**

We will use **Isaac Lab** (built on NVIDIA Omniverse) and Unitree's RL wrapper.

1. **Install NVIDIA Isaac Sim:**  
   * Download [Omniverse Launcher](https://www.nvidia.com/en-us/omniverse/).  
   * Install **Isaac Sim** (Version 4.0+ recommended).  
2. **Clone the Unitree RL Repository:**  
   * This repo bridges Isaac Sim with the G1 robot logic.

Bash  
git clone https://github.com/unitreerobotics/unitree\_rl\_gym  
cd unitree\_rl\_gym  
uv pip install \-e .

### **Step 2: "Hello World" \- Running a Pre-trained Policy**

Verify the setup by viewing a pre-trained robot.

* **Command:**  
  Bash  
  python scripts/play.py \--task=g1\_walk

* **What to watch for:** A simulation window should open. You should see the G1 robot walking in place or moving forward. If it crashes, check your GPU drivers.

## ---

**Phase 2: The Training Loop (Reinforcement Learning)**

Now students will train their own unique brain.

### **Step 1: Configure the Experiment**

Navigate to unitree\_rl\_gym/legged\_gym/envs/g1/g1\_config.py. This file controls the "Game Rules."

* **Challenge for Students:** Modify the linear\_velocity command range. Make the robot learn to walk *faster* than the default.  
* **Code Snippet:**  
  Python  
  class commands(LeggedRobotCfg.commands):  
      class ranges:  
          lin\_vel\_x \= \[-1.0, 1.0\] \# Change this to learn faster walking

### **Step 2: Launch Training**

* **Command:**  
  Bash  
  \# \--headless runs without GUI (much faster training)  
  python scripts/train.py \--task=g1\_walk \--headless

* **Console Output:** You will see a stream of data. Look for Mean Reward.  
  * *Episode 0:* Reward \~0 (Robot falls instantly).  
  * *Episode 500:* Reward increasing (Robot is crawling/stumbling).  
  * *Episode 2000:* Reward stabilizes (Robot is walking).

### **Step 3: Result**

When finished, the script saves a .pt file (e.g., model\_2000.pt) in the logs/ directory. **This file is the robot's new brain.**

## ---

**Phase 3: The Hardware Setup (Safety Critical)**

**STOP.** Do not skip this section. Improper setup will break the $16k+ robot.

### **1\. The Physical Safety Rig**

* **Rule \#1:** The robot must be **suspended** (hung from a ceiling tether or gantry) for all initial tests.
* **Rule \#2:** Keep the robot's feet 5cm off the ground during the first boot.
* **Rule \#3:** Always operate with **two people** — one at the workstation (keyboard e-stop) and one holding the remote controller (L2+B / L2+Y ready).

### **Emergency Stop Procedures**

| Method | How | Effect |
| :---- | :---- | :---- |
| **L2 \+ B** (Primary) | Remote controller | **Damping mode** — joints resist movement, robot holds position. Use this first. |
| **L2 \+ Y** (Secondary) | Remote controller | **Zero torque** — all motors release, robot collapses. Use if damping is not enough. |
| **Backtick (`)** | Keyboard in terminal | Kills the tmux control session, stopping all SDK commands. |

**⚠ Memorize these before powering on the robot. The safety observer must have the remote controller with fingers on L2+B at all times.**

### **2\. Connection Workflow**

1. **Ethernet:** Connect laptop to the robot's Ethernet port.  
2. **IP Settings:** Set your Laptop IP to `192.168.123.222/24`.
3. **SSH into Robot:**
   Bash
   ssh unitree@192.168.123.164
   \# Password: 123

### **3\. Killing the Default "Brain"**

The robot comes with a default OS that makes it walk. We must *silence* this to let our custom RL policy take over.

1. **On the Remote Controller:**
   * First press **L2 \+ B** to enter **Damping Mode** (joints offer gentle resistance, robot does NOT go limp).
   * Then press **L2 \+ R2** to enter **Debug Mode** (releases the built-in locomotion controller, motors now listen for custom SDK commands).
   * *Verify:* The robot should hold position loosely — joints resist movement but the robot is not actively balancing.
   * **⚠ Do NOT use L2 \+ Y (Zero Torque) unless you intend the robot to collapse — that is an emergency stop, not a mode transition.**

## ---

**Phase 4: Sim2Real Deployment**

### **Joint Safety Limits (Critical for Real Hardware)**

The JointSafetyMonitor enforces hard velocity limits. **Exceeding these triggers an immediate `sys.exit(1)` on real hardware.**

| Joint Group | Max Velocity | Notes |
| :---- | :---- | :---- |
| Arm joints | 6.0 rad/s | |
| Hand joints | 50.0 rad/s | |

* Set `upper_body_joint_speed` to **100** rad/s (the default 1000 is unsafe for real hardware).
* Start the publisher with `--speed 0.25` and increase gradually.

### **Step 1: Transfer the Brain**

Move the .pt file from your laptop to the robot.

Bash

\# Run this on your laptop  
scp logs/g1\_walk/model\_2000.pt unitree@192.168.123.164:\~/unitree\_rl\_gym/deploy/

### **Step 2: The Inference Script**

SSH back into the robot. We run a script that loops the generic RL policy.

Bash

cd \~/unitree\_rl\_gym/deploy  
python deploy\_real.py \--model model\_2000.pt

### **Step 3: The "Moment of Truth" Checklist**

1. **Robot Suspended:** Yes.  
2. **Script Running:** Yes.  
3. **Gently Touch Down:** Slowly lower the tether until feet touch the floor.
   * **For GR00T-WBC workflow:** Before lowering, activate the balance policy (`]` key in terminal) and release the elastic band (`9` key). The robot will NOT balance automatically without these steps.
4. **Observation:**
   * *Success:* The robot detects contact and starts stepping to maintain balance.
   * *Failure:* The robot shakes violently (High-Frequency Oscillation). **Action:** Lift immediately and kill script (Ctrl+C or backtick for tmux e-stop).

## ---

**Resources & Documentation**

### **Required Reading for Instructor**

1. **Official Unitree G1 Developer Guide:**  
   * *Contains:* Pinouts, Safe Startup procedures, SDK details.  
   * [Link to Unitree Docs](https://support.unitree.com/home/en/G1_developer)  
2. **Unitree RL Gym Repository:**  
   * *Contains:* The actual code students will use.  
   * [Link to GitHub](https://github.com/unitreerobotics/unitree_rl_gym)  
3. **NVIDIA Isaac Lab Docs:**  
   * *Contains:* How to modify the simulation environment.  
   * [Link to Docs](https://isaac-sim.github.io/IsaacLab/)

### **Video Resources for Class**

* **Sim2Real Explained (Concept):** [OpenAI "Learning Dexterity" (YouTube)](https://www.youtube.com/watch?v=jwSbzNHGflM) \- *Best visual explanation of Domain Randomization.*  
* **Unitree G1 Teaser:** [Official G1 Video](https://www.youtube.com/watch?v=zGFq69N7tQM) \- *To get students hyped.*

## ---

**Artifact: The Student "Flight Checklist"**

*Print this out and tape it to the robot station.*

| Step | Action | Verification |
| :---- | :---- | :---- |
| **1\. Safety** | Check Gantry/Tether | Robot is secured and hanging freely. |
| **2\. Battery** | Check Voltage | Battery \> 20% charge. |
| **3\. Mode** | **Damping Mode** | Robot joints offer resistance but do not move on their own. |
| **4\. Network** | Ping Robot | ping 192.168.123.164 returns success. |
| **5\. Controller** | **Kill Default High-Level** | Press L2+R2 (or firmware specific combo) \-\> Robot enters Debug/Low-Level. |
| **6\. Deploy** | Run Python Script | Terminal shows "Waiting for control loop..." |
| **7\. Action** | **Start** | Press Start on script/Controller. Legs begin to move. |
| **8\. Landing** | **Touchdown** | Slowly lower gantry. Robot accepts weight. |

# **Minimal G1 Ethernet Steps**

Running a custom policy model on a Unitree G1 via a wired laptop connection involves setting up a control loop where your laptop reads the robot's state, computes an action using your model, and sends the command back to the robot.

Here is the step-by-step workflow to get your policy controlling the G1.

### **1\. Hardware Connection & Network Setup**

First, establish a robust, low-latency connection between your laptop and the robot.

* **Ethernet Connection:** Connect your laptop directly to the robot's Ethernet port.  
* **IP Configuration:** The G1's onboard computer (Orin NX) is at `192.168.123.164`. Set your laptop's Ethernet adapter to a static IP of `192.168.123.222/24`.
* **Verify Connection:** Use `ping 192.168.123.164` to ensure you have a connection with low latency (ideally \<1ms for stable control).

### **2\. Install the Unitree SDK (unitree\_sdk2)**

Unitree provides an SDK to interface with the robot. The G1 typically uses `unitree_sdk2` (distinct from the older SDK used for the Go1/A1).

* **Clone the Repository:**  
  Bash

```
git clone https://github.com/unitreerobotics/unitree_sdk2
```

*   
* **Build the SDK:** Follow the `README` instructions to build the libraries using CMake.  
* **Set Permissions:** You may need to run your scripts with `sudo` or configure memory locking limits (`ulimit -l`) because high-frequency control often requires real-time priority.

### **3\. Understand the Control Interface**

You will likely be working with the **Low-Level Control** interface if you are running a custom RL policy that outputs joint positions (q), velocities (dq), or torques (tau).

* **LowState:** This struct contains the feedback from the robot (IMU data, current joint angles, joint velocities).  
* **LowCmd:** This struct is where you write your commands.  
* **Damping & Stiffness (Kp/Kd):** RL policies often output target joint positions. To execute these, you generally set a stiffness (Kp​) and damping (Kd​) in the command struct to act as a PD controller at the actuator level.

### **4\. Wrapper Script (The "Bridge")**

You need to write a script (usually in Python or C++) that bridges your policy model and the SDK. This script acts as the main control loop.

**The Loop Structure (running at \~50Hz \- 200Hz):**

1. **Receive Observation:** Call the SDK method (e.g., `Recv()`) to get the latest `LowState`.  
2. **Process State:** Convert the raw SDK data (quaternions, joint angles) into the exact tensor format your policy expects (normalization, ordering).  
3. **Inference:** Pass the processed state to your policy model (PyTorch, ONNX, etc.) to get the action.  
4. **Process Action:** Convert the model's output (usually scaled actions in range \[-1, 1\]) back into physical units (radians, Nm).  
5. **Send Command:** Populate the `LowCmd` struct with the calculated targets, Kp​, and Kd​, and send it to the robot using `Send()`.

### **5\. Safety Checks (Crucial\!)**

Before letting your policy take full control, implement software safety guards in your wrapper script.

* **Joint Limits:** Clamp commands to stay within the physical limits of the G1 joints.  
* **Velocity Limits:** prevent the robot from trying to move instantly to a far-off target.  
* **Emergency Stop:** Map a key on your laptop keyboard or a joystick button to instantly send zero-torque or damping-only commands (set Kp​=0,Kd​=5) to make the robot go limp/passive safely.

### **6\. Deployment & Testing**

1. **Suspend the Robot:** Initially, hang the G1 on a gantry or stand so its feet are not touching the ground. This prevents it from falling if the policy behavior is erratic.  
2. **Zero-Action Test:** Run your loop but send 0 torque/damping commands (or very low damping) to verify the data reading pipeline works without the robot moving.  
3. **Damping Test:** Send a command with only Damping (Kd​≈1−5) and 0 Stiffness (Kp​=0). The robot should feel "viscous" or resistant to movement but shouldn't move on its own.  
4. **Live Run:** With the robot suspended, enable the policy. Verify the legs move as expected (e.g., walking motion).  
5. **Ground Test:** Once confident, place the robot on the ground and run the policy.

---

### **Important Technical Note on Real-Time Control**

If you are running this over Ethernet, you are subject to network jitter. While usually fine for high-level commands, low-level torque control at high frequencies (500Hz+) can be unstable over standard Ethernet.

* **Frequency:** Ensure your Python/C++ loop runs consistently. If your model inference is heavy, it might delay the control signal.  
* **Latency:** Monitor the round-trip time. If you miss too many control cycles, the robot's internal safety watchdog might cut power to the motors.

**Would you like me to generate a template Python script for the "Bridge" using `unitree_sdk2` and PyTorch?**

# **Isaac Sim (Docker+linux) Command**

docker run \--name isaac-sim \--entrypoint bash \-it \--gpus all \-e "ACCEPT\_EULA=Y" \--rm \` \-p 8211:8211 \` \-p 49000-49100:49000-49100/udp \` \-v $HOME/docker/isaac-sim/cache/kit:/isaac-sim/kit/cache:rw \` \-v $HOME/docker/isaac-sim/cache/ov:/root/.cache/ov:rw \` \-v $HOME/docker/isaac-sim/cache/pip:/root/.cache/pip:rw \` \-v $HOME/docker/isaac-sim/cache/glcache:/root/.cache/nvidia/GLCache:rw \` \-v $HOME/docker/isaac-sim/cache/computecache:/root/.nv/ComputeCache:rw \` \-v $HOME/docker/isaac-sim/logs:/root/.nvidia-omniverse/logs:rw \` \-v $HOME/docker/isaac-sim/config:/root/.nvidia-omniverse/config:rw \` [nvcr.io/nvidia/isaac-sim:4.2.0](http://nvcr.io/nvidia/isaac-sim:4.2.0)

### **Step 3: Start the WebRTC Stream**

Once inside the container terminal, do **not** run `runheadless.native.sh`. Instead, run the WebRTC script:

Bash

```
./runheadless.webrtc.sh
```

*(If that specific script name has changed in your specific image version, look for `./runheadless.sh` and pass the argument `--enable-ext omni.services.streamclient.webrtc`)*.

Wait for the logs to settle. You are looking for a line that says: `[WebRTC Streaming] Server listening at ws://0.0.0.0:8211`

### **Step 4: Connect via Browser**

1. Open **Google Chrome** or **Microsoft Edge** on your Windows desktop.  
2. Navigate to: `http://127.0.0.1:8211/streaming/webrtc-client/`  
3. You should see the Isaac Sim viewport render directly in the browser window.

For isaac sim 5.1.0 and running in persistent mode:  
docker run \--name isaac-sim \-d \--gpus all \`  
  \-e "ACCEPT\_EULA=Y" \--network=host \`  
  \-e "HOME=/home/isaac-sim" \`  
  \-v "${HOME}/docker/home:/home/isaac-sim" \`  
  \-v "${HOME}/docker/isaac-sim/cache/main:/isaac-sim/.cache:rw" \`  
  \-v "${HOME}/docker/isaac-sim/cache/computecache:/isaac-sim/.nv/ComputeCache:rw" \`  
  \-v "${HOME}/docker/isaac-sim/logs:/isaac-sim/.nvidia-omniverse/logs:rw" \`  
  \-v "${HOME}/docker/isaac-sim/config:/isaac-sim/.nvidia-omniverse/config:rw" \`  
  \-v "${HOME}/docker/isaac-sim/data:/isaac-sim/.local/share/ov/data:rw" \`  
  \-u 0 \`  
  \--restart unless-stopped \`  
  nvcr.io/nvidia/isaac-sim:5.1.0 \`  
  tail \-f /dev/null

This is the good command to start the docker container (uses the local docker container on the Windows machine)  
docker run \--name isaac-sim \-d \--gpus all \`  
\-e "ACCEPT\_EULA=Y" \--network=host \`  
\-e "HOME=/root" \`  
\-v "${HOME}/docker/home:/root" \`  
\-v "${HOME}/docker/isaac-sim/cache/main:/root/.cache:rw" \`  
\-v "${HOME}/docker/isaac-sim/cache/computecache:/root/.nv/ComputeCache:rw" \`  
\-v "${HOME}/docker/isaac-sim/logs:/root/.nvidia-omniverse/logs:rw" \`  
\-v "${HOME}/docker/isaac-sim/config:/root/.nvidia-omniverse/config:rw" \`  
\-v "${HOME}/docker/isaac-sim/data:/root/.local/share/ov/data:rw" \`  
\-u 0 \`  
\--restart unless-stopped \`  
isaac-sim:latest \`  
tail \-f /dev/null

Run this to connect to the container with bash  
docker exec \-it isaac-sim bash

TODO: move the unitree stuff to the home directory so that the files are accessible in windows

# **Linux native installation**

Followed 

[https://merox.dev/blog/windows-11-ubuntu-25-04-dual-boot-guide/](https://merox.dev/blog/windows-11-ubuntu-25-04-dual-boot-guide/)  
Image is on the green USB  
To enter the boot mode, press F11 during startup

##   **Isaac sim**

follow  
[https://isaac-sim.github.io/IsaacLab/main/source/setup/installation/pip\_installation.html](https://isaac-sim.github.io/IsaacLab/main/source/setup/installation/pip_installation.html)  
Add   
export UV\_CONCURRENT\_DOWNLOADS=1  
export UV\_HTTP\_TIMEOUT=600  
For faster install

# **G1 Ethernet connection**

Following the instruction on [this webpage](https://support.unitree.com/home/en/G1_developer/quick_development)

Download SDK code:  
git clone [https://github.com/unitreerobotics/unitree\_sdk2.git](https://github.com/unitreerobotics/unitree_sdk2.git)

Get necessary packages:  
sudo apt install cmake

Additional (required for some examples)  
sudo apt-get update && sudo apt-get install \-y libeigen3-dev  
sudo apt-get install \-y libyaml-cpp-dev && sudo make install

Step 1: Installing unitree\_sdk2

To install unitree\_sdk2, navigate to the unitree\_sdk2 directory and run the following commands:

cd unitree\_sdk2/  
mkdir build  
cd build  
cmake ..  
sudo make install

Step 2:

Get the interface name  
Run one of these:

ip \-br link  
ip \-br addr

ip \-br addr show enp39s0  
cat /sys/class/net/enp39s0/operstate

1\) Bring the interface up  
sudo ip link set enp39s0 up

2\) Give it an IP on the robot subnet  
sudo ip addr add 192.168.123.222/24 dev enp39s0

(If it says “File exists”, you already have an address there.)  
3\) Verify  
ip \-br addr show enp39s0  
cat /sys/class/net/enp39s0/operstate

Dec 17, 2025

The physical deployment guide (where to take this)

[https://github.com/unitreerobotics/unitree\_rl\_gym/blob/main/deploy/deploy\_real/README.md](https://github.com/unitreerobotics/unitree_rl_gym/blob/main/deploy/deploy_real/README.md)

# **SSH into Jetson on G1**

**Minimal working instructions: Ethernet \+ SSH into a Unitree G1**

1. **Plug in Ethernet**

Connect your computer directly to the robot with an Ethernet cable.

**Turn on the network port**  
sudo ip link set enp39s0 up

The robot does not give out IP addresses over Ethernet.

**Set a manual IP (important)**  
sudo ip addr flush dev enp39s0  
sudo ip addr add 192.168.123.222/24 dev enp39s0

**Check it worked**  
ip a show enp39s0

You should see:  
inet 192.168.123.10/24 or inet 192.168.123.222/24

**Test connection to the robot**  
ping 192.168.123.164

(This is the robot’s Linux computer.)

**SSH into the robot**  
ssh unitree@192.168.123.164

Password:  
123

# **Lidar and Camera input**

To stream **LiDAR** data into the deploy controller you wire it up exactly the same way the low‑state topic already is.

  Add config knobs

  \- In deploy/deploy\_real/configs/\*.yaml introduce entries such as lidar\_topic: "rt/lidar" and (optionally) lidar\_points: 720 / lidar\_scale: 1.0.  
  \- Bump num\_obs to account for however many beams you’ll pass to the policy (e.g. \+720 if you pack all beams directly into the observation vector). Document these additions so contributors know they must keep the  
    policy checkpoint in sync.

  Import the DDS message & hold state

  \- Near the other imports in deploy/deploy\_real/deploy\_real.py:7-15 add the LiDAR message definitions, e.g.

    from unitree\_sdk2py.idl.default import unitree\_lidar\_msg\_dds\_\_LidarPointCloud\_  
    from unitree\_sdk2py.idl.unitree\_lidar.msg.dds\_ import LidarPointCloud\_ as LidarPointCloud  
    (adjust the exact class if your SDK exposes LidarState\_ or PointCloud\_).  
  \- In Controller.\_\_init\_\_ store the latest packet:

    self.lidar\_state \= unitree\_lidar\_msg\_dds\_\_LidarPointCloud\_()  
    self.lidar\_ready \= False  
    self.lidar\_subscriber \= ChannelSubscriber(config.lidar\_topic, LidarPointCloud)  
    self.lidar\_subscriber.Init(self.LidarHandler, 10\)  
  \- Implement LidarHandler right next to LowStateGoHandler so it simply copies the message and flips self.lidar\_ready \= True.

  Wait for data before running

  \- Extend wait\_for\_low\_state to also check self.lidar\_ready (or create a second wait) so you don’t start the controller without valid scans.

  Inject LiDAR into the observation

  \- Decide how many floats your policy expects (raw ranges, down‑sampled bins, nearest obstacle pose, etc.).  
  \- In Controller.run after you compute self.obs\[9 \+ num\_actions \* 3\] add something like:

    ranges \= np.array(self.lidar\_state.ranges, dtype=np.float32)  
    lidar \= ranges\[: self.config.lidar\_points\] \* self.config.lidar\_scale  
    start \= 9 \+ num\_actions \* 3 \+ 2  
    self.obs\[start : start \+ lidar.size\] \= lidar  
    Update num\_obs accordingly in configs/checkpoints.

  Pass data to the policy

  \- With the observation vector larger, retrace any TorchScript model you plan to deploy so num\_obs in the config matches the traced module’s input size; otherwise the torch.jit.load call at deploy/deploy\_real/  
    deploy\_real.py:23 will error when fed a longer tensor.

  Optional post‑processing

  \- If you only need high‑level features, do that before storing them in self.obs (min range per sector, collision flags, etc.).  
  \- When pushing LiDAR to a different node (e.g., for debugging) reuse the subscriber callback to emit ROS/CSV logs.

  These changes keep the structure of deploy/deploy\_real/deploy\_real.py intact: you add one subscriber and extend the observation assembly. No other parts of the control loop need to change unless the policy  
  consumes LiDAR to produce different actions.

To wire **camera** frames into the hardware controller you follow the same pattern used for low\_state, just with the Unitree image topic.

  \- Expose config knobs: in each deploy/deploy\_real/configs/\*.yaml add fields such as camera\_topic: "rt/front\_camera", camera\_width, camera\_height, and a camera\_mode (rgb/gray). Also bump num\_obs if you plan to  
    concatenate image features onto the observation vector. Make sure the TorchScript policy you deploy was traced with the same observation size.  
  \- Import and subscribe (deploy/deploy\_real/deploy\_real.py, around the import block at the top and the constructor at deploy/deploy\_real/deploy\_real.py:20):

    from unitree\_sdk2py.idl.default import unitree\_camera\_msg\_dds\_\_Image\_  
    from unitree\_sdk2py.idl.unitree\_camera.msg.dds\_ import Image\_ as CameraImage

    Inside Controller.\_\_init\_\_ store the latest frame and hook up a subscriber:

    self.camera\_frame \= None  
    self.camera\_ready \= False  
    if self.config.camera\_topic:  
        self.camera\_subscriber \= ChannelSubscriber(self.config.camera\_topic, CameraImage)  
        self.camera\_subscriber.Init(self.CameraHandler, 10\)

    Then implement CameraHandler next to LowStateGoHandler:

    def CameraHandler(self, msg: CameraImage):  
        self.camera\_frame \= np.frombuffer(msg.data, dtype=np.uint8)  
        self.camera\_frame \= self.camera\_frame.reshape(self.config.camera\_height,  
                                                      self.config.camera\_width,  
                                                      self.config.camera\_channels)  
        self.camera\_ready \= True

    Extend wait\_for\_low\_state() so it also waits for self.camera\_ready when camera\_topic is set, preventing the loop from running before a frame arrives.  
  \- Preprocess before policy input (Controller.run, roughly lines 87‑150): decide how the policy consumes vision. Options:  
      1\. Flatten & append: resize/downsample the image (e.g., with OpenCV inside the callback) and stuff it into self.obs\[start:end\]. Keep it small (e.g., 32×32 grayscale → 1024 floats) or you’ll blow up num\_obs.  
      2\. Feature extractor: run a lightweight CNN or handcrafted feature extractor in Python, then append only the resulting embedding (e.g., 64 floats) to self.obs. This keeps the existing MLP policy viable.  
      3\. Separate vision policy: if you retrain a policy that natively accepts images, replace the TorchScript module with that traced network; in this case you’d stack the raw tensor and call the module with both  
         proprioception and pixels.

    Example augmentation at the end of the observation assembly:

    if self.camera\_ready:  
        \# downsample & grayscale  
        small \= cv2.resize(self.camera\_frame, (32, 32))\[:, :, 0\].astype(np.float32) / 255.0  
        start \= 9 \+ num\_actions \* 3 \+ 2  
        self.obs\[start : start \+ small.size\] \= small.flatten()

    Remember to import cv2 only if it’s in your environment; otherwise roll a simple mean-pooling downsampler.  
  \- Performance considerations: the camera topic is heavy, so keep the subscriber queue depth low (10 is fine) and do minimal work inside CameraHandler (copy and reshape only). More expensive processing (OpenCV,  
    torch ops) should happen in run() or a dedicated worker thread.  
  \- Policy retraining: any vision-aware policy must be retrained/traced with the new observation definition before you drop it into deploy\_real. Otherwise torch.jit.load will accept the module but the forward pass  
    will fail because of the unexpected input size.

  This approach keeps deploy/deploy\_real/deploy\_real.py structured like today’s version: one new subscriber, a callback that caches the latest frame, and a small extension to the observation builder so the policy  
  can consume camera-derived information.

# **Low level control representations**

https://github.com/unitreerobotics/unitree\_sdk2\_python/blob/master/example/g1/low\_level/g1\_low\_level\_example.py

# **Ryan ideas**

**https://docs.google.com/document/d/1nB0O2PMIJ1lYWeAb37TYOTPj7q0LIIlm7W\_WJAsrYX8/edit?tab=t.opsj231tbal3Ryan idea:**   
Python script project that just stays at the high level, while reading some settings from low level. 

**Quick Links:**  
[https://github.com/Acciorocketships/UnitreeController/tree/main](https://github.com/Acciorocketships/UnitreeController/tree/main) 

**Notes from Work days:**  
Robot needs to be in READY mode

Problems and Workarounds

- Issue: Waiting for the start signal…  
  - Cause: the default deploy\_real.py waits until there is a start signal in zero\_torque\_state, but we don’t know how to give the start signal  
  - Solution: remove the infinite loop in zero\_torque\_state  
- Issue: Robot not moving  
  - Solution: put robot in ready mode **not developer mode and not Debug mode**

**Notes for gabe to study to run lesson:**

# **Lesson Plan: Unitree G1 EDU Humanoid Robot – Ball Navigation Project**

This project establishes a **Minimum Viable Product (MVP)** for high school computer science students to interact with the Unitree G1 EDU humanoid robot using Python. The objective is to navigate the robot to a soccer ball and physically kick it.

---

## **📋 Project Overview: "Search & Kick"**

Students will develop a Python script that leverages the robot's onboard sensors (Camera and LiDAR) to identify a specific object and execute a movement policy.

* **Objective:** Navigate to a ball and perform a kick action.  
* **Target Audience:** High School Computer Science students.  
* **Core Concepts:** Sensor input processing (color thresholding), high-level command logic, and hardware abstraction.

---

## **🛠️ Step-by-Step Tutorial Guide**

### **Step 1: Interface with the Robot Computer**

Students do not need to manage low-level networking or PD controller tuning. You will use a pre-configured **unified interface**.

* Open the deployment environment on the robot's computer.  
* Ensure the robot is in its "basic balancing" mode.   
  * Gabe boot up, L2 \+ B, L2 \+ UP. then run Ryan’s code via ethernet. 

### **Step 2: Define Sensor Inputs (LiDAR & Vision)**

Your script will receive a stream of data from the robot's head-mounted sensors.

* **Camera:** Used for identifying the color and "blob" of the ball.  
* **LiDAR:** Provides 3D coordinates to determine the exact distance to the ball

### **Step 3: Implement Navigation Logic**

Students will write logic inside a standardized Python function where the inputs (sensor data) and outputs (robot actions) are already defined

| Level | Method | Logic Description |
| :---- | :---- | :---- |
| **Standard** | **Color Thresholding** | Look for blue pixels; if the largest blue "blob" is right of center, turn right |
| **Advanced** | **3D Pose Estimation** | Use LiDAR and math libraries to calculate the ball's exact 3D coordinates |

### **Step 4: Execute the Policy**

Once the ball is reached, the script triggers the high-level "kick" command

1. Open the Run script  
2. Change the policy line: policy \= student\_ball\_policy  
3. Run the script to see the robot navigate and kick the ball

---

## **🧪 Answer Key: "The Reference Solution"**

A successful project completion should look like the following logic flow:

1. **Search:** Robot rotates until the camera detects a blue color threshold  
2. **Approach:** Robot moves forward while centering the "blue blob" in the camera frame  
3. **Distance Check:** LiDAR confirms the robot is within kicking range (e.g., \< 0.5 meters)  
4. **Action:** The script sends the kick action command to the high-level policy

---

## **🚀 2026 Stretch Goals: AI & LLM Integration**

For students who complete the MVP early, the following "fun" experimental features can be explored:

* **VLM Integration:** Use a **Qwen3-VL** or **Llama** model (8B version) to process images locally  
* **Natural Language Commands:** Instead of hardcoded logic, the robot can follow typed prompts like "Follow the red ball  
* **Positional Grounding:** Use the vision model to create bounding boxes around objects for more precise navigation

---

## **Teacher’s Deep-Dive Study Guide: Unitree G1 EDU Project**

This guide provides a technical foundation and pedagogical roadmap for the "Search & Kick" assignment. It combines machine learning theory with the specific workflow for the Unitree G1 humanoid robot

### ---

**Section 1: Core Machine Learning Concepts**

As a teacher, you need to understand how the robot "learns" to bridge the gap between simple Python logic and advanced AI.

#### **1\. Offline Reinforcement Learning (RL)**

* **Deep Dive:** Unlike traditional RL that requires a robot to learn via trial-and-error in real-time, Offline RL uses a pre-collected "static" dataset2.  
* **Why for G1:** It prevents the robot from falling and breaking while "learning"3. You collect data once (e.g., manual walking) and train the policy on a computer4.

#### **2\. Behavioral Cloning (BC)**

* **Deep Dive:** The simplest form of imitation learning. The robot maps specific observations (images/LiDAR) directly to actions (joint movements) based on how a human performed the task5.

* **Classroom Application:** This is the "debugging" phase. If the robot can’t clone a simple human-controlled walk, the data collection or interface is likely broken6666.

#### **3\. Goal-Conditioned Policy**

* **Deep Dive:** A policy that takes a specific target as an input variable (e.g., $Goal \= \[x, y\]$)7.

* **Implementation:** Students will use this to tell the robot "go to the ball"8888. The "brain" doesn't just walk; it walks *toward* the input goal9999.

#### **4\. Hindsight Experience Replay (HER)**

* **Deep Dive:** A strategy for dealing with "sparse rewards." If a student's code fails to kick the ball but moves toward a different object, HER treats that "failure" as a "success" for the accidental goal10101010.

* **Classroom Logic:** This helps students understand that "failed" data is still valuable for training AI models.

### ---

**Section 2: The Technical Infrastructure**

Before students code, the "setup stuff" must be handled to allow them to focus on logic11111111.

* **The Interface:** The system uses a **Unified Interface** where students write a "policy" (a Python class)12121212.

* **Sensor Inputs:**  
  * **Camera:** Used for "color thresholding" to find the ball13.

  * **LiDAR:** Provides 3D coordinates so the robot knows exactly how far away the ball is14141414.

* **The Sport Client:** A high-level controller that handles the "basic balancing" so students don't have to program individual motor torques15151515.

### ---

**Section 3: Student Assignment Walkthrough**

**Project Goal:** Write a Python script to navigate to a ball and kick it16161616.

#### **Step A: Data Collection (The "Offline Dataset")**

* **Student Task:** Manually move the robot using a script or remote while recording17171717.

* **Teacher Note:** Ensure they record **motor positions**, **linear velocities**, and **camera frames**181818.

#### **Step B: The Logic Loop**

Students will implement a "Main Loop" with the following steps:

1. **Observation:** Get the image and LiDAR data19.

2. **Processing:** Identify the "blue blob" (the ball)20.

3. **Action Selection:** \* If ball is to the left $\\rightarrow$ Action: Turn Left21.

   * If ball is centered and close $\\rightarrow$ Action: Kick22222222.

4. **Execution:** Send the command to the robot23.

#### **Step C: Testing & Abstraction**

* Students will swap their policy file into the main Run script24242424.

* **Abstraction Goal:** Students shouldn't worry about networking or networking "tags"; they should only focus on the if/else logic of the policy25252525.

### ---

**Section 4: Advanced Extensions (2026 Goals)**

For high-performing students:

* **VLM (Vision Language Models):** Use the **Qwen2-VL** model to let the robot "understand" the scene26.

* **Prompting:** Allow the robot to take commands like "Follow the person" via an LLM interface27272727.

* **Positional Grounding:** Use AI to draw a "bounding box" around the ball for more precise kicking28.

# **Inventory List**

Backup inventory list and details  
Robot Parts:  
[https://drive.google.com/drive/folders/1mj-Hu4tmJZk9W3Zk5bAwRsVAmthaJh7S](https://drive.google.com/drive/folders/1mj-Hu4tmJZk9W3Zk5bAwRsVAmthaJh7S)

Lab Equipment:

# **Dream Projects**

Get robot to do it just by itself that only interacts with ground.

More challenges some interaction with environment. 

Stretch goals: voice controls.   
Grab 2 malasadas.  
It goes and grabs 2 malasadas.

Create video or upload video based on performances from Iolani art students and have the robot learn

GitHub \- AIM-Intelligence/video2robot: End-to-end pipeline converting generative videos (Veo, Sora) to humanoid robot motions [https://share.google/x49aMzosax6QnF3G1](https://share.google/x49aMzosax6QnF3G1)

Have the robot do the Hawaiian bowling activity or just grabs a stone and rolls it 

Dinosaur for Kualoa [https://www.reddit.com/r/Dinosaurs/comments/1o7krp3/in\_changzhou\_dinosaur\_park\_they\_let\_a\_unitree/](https://www.reddit.com/r/Dinosaurs/comments/1o7krp3/in_changzhou_dinosaur_park_they_let_a_unitree/)  
We make robots for Kualoa Ranch

Motion capture to train animation in the robot we sell on the market/app store.   
Westlake Robotics GAE mode   
[https://www.youtube.com/watch?v=QBef1Od1b9I](https://www.youtube.com/watch?v=QBef1Od1b9I)  
[https://www.youtube.com/watch?v=TVwPwbmTvL8](https://www.youtube.com/watch?v=TVwPwbmTvL8)  
 ChingMu optical motion capture system  
[https://github.com/Westlake-AGI-Lab](https://github.com/Westlake-AGI-Lab)  
[https://github.com/westlake-autolab](https://github.com/westlake-autolab)  
[https://westlake-autolab.github.io/people.html](https://westlake-autolab.github.io/people.html)  
[https://github.com/MingkunLei](https://github.com/MingkunLei)  
[https://www.noitom.com/](https://www.noitom.com/)  
[https://www.westlake.edu.cn/](https://www.westlake.edu.cn/)

Starting project: reach out to all the public schools on the island and have them 3D print, custom arms and hands and mounts for our robot. 

This is achieved by 1\) get a human reference, 2\) (optional) use optimization/learning-based methods to convert the human reference into a robot-morph reference, and 3\) use reinforcement learning to train a (phase-based) controller that tracks the reference.

Some highly related papers:  
Similar pipeline: https://arxiv.org/abs/2502.01143  
Reference tracking by RL: https://arxiv.org/abs/1804.02717  
The infra behind all unitree and other companies' RL demos: https://arxiv.org/abs/2109.11978  
Other related works you can find if you wanna do such research: https://github.com/zita-ch/bipedal-robot-learning-collection

# **Go2 Ethernet connection**

## 

### **1\) Put your PC on the Go2 subnet**

sudo ip addr flush dev enp39s0  
sudo ip addr add 192.168.123.100/24 dev enp39s0  
sudo ip link set enp39s0 up

### **2\) Verify link and addressing**

ip \-br addr show enp39s0

### **3\) Use the robot IP you confirmed**

* **Robot/controller IP:** `192.168.123.18`

you should connect/ping:

ping 192.168.123.18

# **pubkeys**

Hosts:

go2:

ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFgzGmoDm29vrBG/CYOubr8jozjKhQFTup7y1dZGHM5S iolani@iolani-MS-7C37

G1:

ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+tR+aIZBxcRxNV5rSVoSxSlKuxqrsLpOaCFmHy+iUc esports@esports-MS-7C37

Anton’s laptop:

ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGw1acOIMQO0EPjwa+YLk0BmZgR061ZeXm9SfyiqRsok anton@Antons-MacBook-Pro-4.local

# **Gabe Currilum**

# **Advanced Machine Learning & Robotics: High School Curriculum**

This curriculum is designed for a year-long progression from foundational AI concepts to advanced Reinforcement Learning (RL) deployment on the Unitree Go2 (quadruped) and G1 (humanoid) platforms.

## **Part 1: Foundations and Philosophy**

### **1.1 The Mentality of Modern Robotics**

Robotics in the age of AI follows the "Sim-to-Real" paradigm. We do not manually program every joint movement. We design environments where robots learn through trial and error.

### **1.2 Core Vocabulary (The Mathematical Framework)**

All robotics ML is built on the Markov Decision Process (MDP).

* **Agent (**$A$**):** The robot (Go2 or G1).  
* **Environment (**$E$**):** The simulation or physical world.  
* **State (**$s$**):** The input vector. Includes joint angles, velocities, and orientation from the IMU.  
* **Action (**$a$**):** The output vector. Usually target joint positions or motor torques.  
* **Reward (**$r$**):** The scalar feedback. Positive for desired behavior (walking forward), negative for failure (falling).  
* **Policy (**$\\pi$**):** The neural network "brain" that maps states to actions.

### **1.3 Why Simulation Matters**

Training on hardware is slow and dangerous.

1. **Safety:** A robot falling 10,000 times destroys expensive motors ($16k+ per unit).  
2. **Time:** Simulation runs at thousands of frames per second. One hour of simulation can equal years of real-world experience.

## **Part 2: Technical Environment Setup (Ubuntu)**

### **2.1 Hardware Requirements**

* **Workstation:** NVIDIA RTX GPU (3070 or better), 32GB RAM, Ubuntu 22.04 LTS.  
* **Network:** Dedicated 5GHz WiFi Router or direct Ethernet connection.

### **2.2 Software Installation**

Students will use the NVIDIA Isaac Lab environment. Use these environment variables to speed up installation:

```
export UV_CONCURRENT_DOWNLOADS=1
export UV_HTTP_TIMEOUT=600
```

1.   
   **Install Isaac Sim:** Download via Omniverse Launcher.  
2. **Clone Isaac Lab:**

```
git clone [https://github.com/isaac-sim/IsaacLab.git](https://github.com/isaac-sim/IsaacLab.git)
cd IsaacLab && ./isaaclab.sh --install
```

3.   
   **Unitree SDK2:** Essential for hardware communication.

```
git clone [https://github.com/unitreerobotics/unitree_sdk2_python](https://github.com/unitreerobotics/unitree_sdk2_python)
cd unitree_sdk2_python && uv pip install -e .
```

### **2.3 The "Stuttering" Fix (Crucial Lesson Learned)**

If the robot stutters during deployment, it is often a Data Distribution Service (DDS) conflict. Set the `CYCLONEDDS_URI` to point to the correct network interface in your `.bashrc`:

```
export CYCLONEDDS_URI='<CycloneDDS><Domain><General><NetworkInterfaceAddress>enp39s0</NetworkInterfaceAddress></General></Domain></CycloneDDS>'
```

## **Part 3: Capstone Project 1 — RL Locomotion**

### **Phase A: Policy Brainstorming**

Students must propose a novel movement policy. Examples:

* **The Stealth Walk:** Extremely low profile, slow joint movements, minimal foot-stamping.  
* **The Celebration Jiggle:** A rhythmic balance-shifting movement triggered upon reaching a goal.

### **Phase B: Reward Function Design**

Students modify `g1_config.py` or `go2_config.py`.

* **Velocity Reward:** $r\_{vel} \= \\exp(-||v\_{current} \- v\_{target}||^2 / \\sigma^2)$  
* **Smoothness Penalty:** Penalize high joint acceleration to prevent "ripping arms off" (a recorded failure mode).

### **Phase C: Training in Isaac Sim**

Run the training script (headless for speed):

```
python scripts/train.py --task Isaac-Velocity-Flat-G1-v0 --headless
```

Monitor progress via **Weights & Biases**. Look for the "Mean Reward" curve to plateau.

### **Phase D: Hardware Deployment (The "Flight Checklist")**

1. **Gantry Mandate:** The G1 **must** be suspended from the ceiling tether.  
2. **Mode Check:** Set robot to "Damping Mode" (L2 \+ B combo).  
3. **SSH Connection:** `ssh unitree@192.168.123.164` (Password: `123`).  
4. **Touchdown:** Slowly lower the tether until the feet accept the weight.

## **Part 4: Capstone Project 2 — Video2Robot (Performing Arts)**

### **Concept**

Using student-recorded dance performances to generate humanoid motions.

### **The Pipeline**

1. **Recording:** Arts students record 10 seconds of a dance move (MP4).  
2. **Pose Estimation:** Use **PromptHMR** or **ViTPose** to extract 3D human skeletons.  
3. **Retargeting:** Map the human joints to the G1 URDF. This requires scaling human limb lengths to robot limb lengths.  
4. **Sim-Validation:** Play the animation in Isaac Sim first. Check for "Self-Collision" (e.g., robot hands hitting the torso).  
5. **Hardware Sync:** Use the `unitree_sdk2` to stream joint positions.

**Teacher Note:** For "soft movement," implement a PD controller with low $K\_p$ values so the robot doesn't strike its own frame with excessive force.

## **Part 5: Capstone Project 3 — Fabrication & Custom Gaits**

### **The Dino-Exoskeleton Build**

Design students fabricate a "Raptor" shell for the Go2.

* **Integration:** Students must weigh the shell and update the `payload_mass` parameter in the simulation config.  
* **LiDAR Guard:** The shell must not block the 360-degree vision of the LiDAR unit.

### **The Movement: "The Raptor Skip"**

ML students develop a "Flight-Phase" policy.

1. **Symmetry Constraints:** Enforce synchronous front-left and back-right movements.  
2. **The Skip:** Increase the "Air Time" reward. Penalize the robot if its feet stay on the ground for more than 0.1 seconds during the push-off phase.

## **Part 6: Bonus Capabilities (Untethered Operation)**

### **6.1 WiFi Configuration (Experimental / Future)**

**⚠ All verified deployments use wired Ethernet.** WiFi introduces latency and jitter that can destabilize low-level control loops. This section is aspirational — do not attempt untethered WiFi operation until wired deployment is fully validated.

To run without Ethernet:

1. Connect the robot to a high-speed router.
2. Assign a static IP to the robot on the router level.
3. Configure the `unitree_sdk2` to use the wireless SSID for DDS communication.

### **6.2 Remote Triggers**

Students can create a "Remote Interaction Script" using the robot's onboard Python environment.

* **Button Mapping:** Map the Unitree Remote Controller `R1` button to trigger the "Dino Skip" or "Dance Move."  
* **Visual Trigger:** Use the front-facing camera to detect a "Blue Ball."  
  * **Logic:** If `blue_blob_center_x > screen_width / 2`, then `turn_right()`.

### **6.3 Onboard Inference**

Convert the PyTorch `.pt` model to **ONNX** or **TensorRT**. This allows the robot to run the policy directly on its internal NVIDIA Orin processor, removing the need for a laptop connection during the performance.

## **Part 7: Safety & Ethics (The MOU)**

Every student must sign a Memorandum of Understanding regarding high-torque motors.

* **Rule 1:** Never stand within 3 meters of an un-tethered G1.  
* **Rule 2:** Padded EVA flooring is mandatory for all Go2 tests.  
* **Rule 3:** If the robot vibrates violently (High-Frequency Oscillation), press the Emergency Stop immediately.

# **Gr00t run**

After building gr00t docker container:

Terminal 1:  
Policy server setup:  
cd /home/esports/Documents/unitree/Isaac-GR00T  
uv run python gr00t/eval/run\_gr00t\_server.py \\  
    \--model-path nvidia/GR00T-N1.6-G1-PnPAppleToPlate \\  
    \--embodiment-tag UNITREE\_G1 \\  
    \--use-sim-policy-wrapper

Terminal 2:  
Sim Client:  
gr00t/eval/sim/GR00T-WholeBodyControl/GR00T-WholeBodyControl\_uv/.venv/bin/python \\  
    gr00t/eval/rollout\_policy.py \\  
    \--policy\_client\_host localhost \\  
    \--policy\_client\_port 5555 \\  
    \--n\_episodes 10 \\  
    \--max\_episode\_steps=1440 \\  
    \--env\_name gr00tlocomanip\_g1\_sim/LMPnPAppleToPlateDC\_G1\_gear\_wbc \\  
    \--n\_action\_steps 20 \\  
    \--n\_envs 5

# **Yosub policy models**

[https://drive.google.com/file/d/1kF\_htij68bmXVPT3s2QFHYTM8-o9boYX/view](https://drive.google.com/file/d/1kF_htij68bmXVPT3s2QFHYTM8-o9boYX/view)

Docs that contain instructions on how to run the low level policy on the real robot.  
[https://github.com/haw-ai-i/unitree-pot/blob/dockerize/vla\_controller/README.md](https://github.com/haw-ai-i/unitree-pot/blob/dockerize/vla_controller/README.md)

Setup guide for unitree-rl environment (adapter to run the policy on a real robot):  
[https://github.com/haw-ai-i/unitree-pot/blob/dockerize/docs/environment\_setup\_guide.md](https://github.com/haw-ai-i/unitree-pot/blob/dockerize/docs/environment_setup_guide.md)

# **Hands**

RH56DFTP \- model

Docs for connecting:  
[https://support.unitree.com/home/en/H1\_developer/FTP\_Inspire\_Hand](https://support.unitree.com/home/en/H1_developer/FTP_Inspire_Hand)  
After that in the corresponding env:  
python Vision\_driver.py gets you connected to the visual ui  
You need to make sure that the ip link is added for the whole robot, and then do:  
ping \-c 3 192.168.123.210  
After getting successful ping you can run:  
python Vision\_driver.py gets you connected to the visual ui

Manual control UI interface:  
python hand\_control\_ui.py

**Unitree sim isaaclab plus gr00t wbc IMPORTANT NOTE: motion switcher was disabled on the real interface to connect to isaaclab robot**

**Running the container with hands isaaclab:**  
*\# Allow X11 forwarding for Docker*  
xhost \+local:docker  
*\# Start the container with GPU support*  
cd \~/Documents/unitree/unitree\_sim\_isaaclab  
sudo docker run \--runtime=nvidia \--gpus all \-it \--rm \\  
 \--network host \\  
 \-e DISPLAY=$DISPLAY \\ \# NOTE: This workstation uses DISPLAY=:2, not :0. Verify with `echo $DISPLAY`.  
 \-e NVIDIA\_VISIBLE\_DEVICES=all \\  
 \-e NVIDIA\_DRIVER\_CAPABILITIES=all \\  
 \-v /tmp/.X11-unix:/tmp/.X11-unix:rw \\  
 \-v \~/Documents/unitree/unitree\_sim\_isaaclab:/home/code/unitree\_sim\_isaaclab \\  
 \-v \~/Documents/unitree/inspire\_hand\_ws:/home/code/inspire\_hand\_ws \\  
 unitree-sim:latest /bin/bash

**Then**

cd /home/code/unitree\_sim\_isaaclab  
python sim\_main.py \--device cuda \--enable\_cameras \\  
   \--task Isaac-Move-Cylinder-G129-Inspire-Wholebody \\  
   \--robot\_type g129 \--enable\_inspire\_dds

https://faunarobotics.com/news/the-robot-youre-looking-for-introducing-sprout

# **Discord links and inspiration**

Discord links and inspiration raw data  
MrY  
mry808  
Online

yosub — 2/2/26, 1:39 PM  
I dont think oculus rift would work.

Groot-wbc’s preferred setup is “pico” controller, although there was mention about being able to use htc vive, leapmotion, or joycon as well.

IsaacLab has its own set of preferred hardware which is apple vision pro.  
https://github.com/NVlabs/GR00T-WholeBodyControl/tree/main/gr00t\_wbc/control/teleop/streamers

this is where all the supported “streamers” for gr00t-wbc can be found.  
GitHub  
GR00T-WholeBodyControl/gr00t\_wbc/control/teleop/streamers at main ...  
Software stack for loco-manipulation experiments across multiple humanoid platforms, with primary support for the Unitree G1. This repository provides whole-body control policies, a teleoperation s...  
GR00T-WholeBodyControl/gr00t\_wbc/control/teleop/streamers at main ...  
yosub — 2/2/26, 1:48 PM  
https://isaac-sim.github.io/IsaacLab/main/source/how-to/cloudxr\_teleoperation.html

for isaac sim/lab:

This site says apple vision pro,  meta quest 3, Pico ultra4

manus+vive (for hand tracking)  
Gabriel Y (Iolani School) — 2/2/26, 1:50 PM  
If you find a tutorial for one, I'll grab it. Whichever one is easiest. I'm assuming metaquest is probably the cheapest and most available?  
yosub — 2/2/26, 1:52 PM  
That’s what i have assumed but for some reason meta quest 3 is only available as an part of early access program, im not sure if this means the features are limited  
Gabriel Y (Iolani School) — 2/2/26, 1:57 PM  
Quest 2 won't work?  
yosub — 2/2/26, 1:57 PM  
https://chatgpt.com/share/69813938-d350-800c-b791-8c8c14d352ef

chatgpt says pico is more open in terms of develper access.

https://github.com/XR-Robotics

this has tutorial and demo  
ChatGPT  
ChatGPT \- Supported Hardware for Teleop  
Shared via ChatGPT  
Image  
GitHub  
XR Robotics  
Shape the future of Robotics and AI with XR. XR Robotics has 15 repositories available. Follow their code on GitHub.  
Shape the future of Robotics and AI with XR. XR Robotics has 15 repositories available. Follow their code on GitHub.  
I can google whether quest2 might work  
Gabriel Y (Iolani School) — 2/2/26, 2:00 PM  
If there's any option for hand or video or webcam tracking, that would be the best cuz then we could scale it as an exhibit that people can interact with, otherwise I saw some people use switch controllers or other Stuff. 

But let's just see what we can get working for now, assuming that it's going to be a couple weeks before we actually can get something specific ordered and delivered.  
yosub — 2/2/26, 2:03 PM  
Yes, switch controller would work too for moving hand.  
Gabriel Y (Iolani School) — 2/2/26, 2:07 PM  
Gotcha. So I have switch controllers in the room now for tomorrow. I don't know how they have geospatial data though, I thought they were only velocity. 

I have Oculus rift controllers, and the USB camera sensors, but also don't know how that works depth wise. 

I'll have both of them ready for us and to make sure batteries in case  
yosub — 2/2/26, 2:11 PM  
Do you have quest 2 as well? the docs are inconclusive but it might work out of box if we are lucky  
Gabriel Y (Iolani School) — 2/2/26, 2:12 PM  
I don't. I was just going to post on Reddit or faculty bulletin if anyone had one  
yosub — 2/2/26, 2:13 PM  
I saw on UH library website so i’ll try to borrow from them as well  
Gabriel Y (Iolani School) — 2/3/26, 1:18 PM  
Got two Meta Quest 2s. Will bring Thursday  
Gabriel Y (Iolani School) — 2/3/26, 2:11 PM  
They're charging up.  I'll work on getting them connected to Wi-Fi and then updated.  
Image  
Brian Shu — 2/3/26, 8:10 PM  
@Gabriel Y (Iolani School) Can Yujin and I come tomorrow from 9:00 AM to 1:00 PM?  
igormolybog — 2/4/26, 2:49 PM  
@Yujin @Brian Shu 

(PORT \= 2203 for Brian and 2204 for Yujin)  
(USERNAME \= shu4 for Brian and yujin31 for Yujin)

To test the connection, please run:

On the Workstation (Open the Tunnel)  
Run this to start the reverse SSH tunnel to the Bastion:

./scripts/setup-internal-host.sh workstation-USERNAME 34.44.147.94 bastionadmin $PORT

On the Laptop (SSH Config)  
Add this to the \~/.ssh/config file:

Host bastion  
    HostName 34.44.147.94  
    User bastionadmin  
Host my-workstation  
    HostName localhost  
    Port $PORT  
    User $USERNAME  
    ProxyJump bastion

On the Laptop (Test the Connection)  
Once the workstation tunnel is running and the config is saved, simply run:

ssh my-workstation

Quick Verification (Run on Laptop)

ssh bastion "ss \-tlnp | grep 220"

expected output: 127.0.0.1:2203 or 2204\.   
Yujin — 2/4/26, 9:48 PM  
@Gabriel Y (Iolani School) Can I come in tomorrow to quickly set up the VPS? When would be convenient for you?  
Gabriel Y (Iolani School) — 2/4/26, 11:18 PM  
Yup\! I'll be there.

I've actually been working on a way to make it so you all can have access to the lab anytime without having to wait for me on check-in. 

There's a visitor form we can do with the office so you can come in whenever. I think when I did it it was about 10 minutes and just needed my ID. I'll send more information soon.  
Gabriel Y (Iolani School) — 2/4/26, 11:31 PM  
Also if you and Anton have some time tomorrow, Kim could use an update from us on how things work And maybe two or three project ideas that will be able to run the students through. &¢{\~

She has a lot on her plate right now with AP computer science classes, so wants to kind of map out some potential projects for quarter 4 around the robots. 

So I can start in lesson plans  
igormolybog — 2/5/26, 3:32 AM  
Let's have a meeting with Kim and discuss projects when I get back next week  
Gabriel Y (Iolani School) — 2/5/26, 8:04 AM  
Sounds good, let me know which day you wanna come in and I'll make a calendar invite  
Gabriel Y (Iolani School) — 2/5/26, 9:38 AM  
Giving exam but room is open  
Gabriel Y (Iolani School) — 2/5/26, 1:03 PM  
5/11-5/22 students will have just finished openai gymnasium and will be available to hang with us to do a basic walkthrough on isaac sim and do whatever cool mini projects we want to showcase. not a lot of time, but should be fun\!  
Image  
Gabriel Y (Iolani School) — 2/5/26, 1:22 PM  
Got switch controls working.  
Got remote access for 2 pcs setup  
yosub — 2/5/26, 2:53 PM  
It turns out we can't move the arm with the joycon. it has a gyroscope and accelerometer, which would let us know the orientation of the hand in 3d space, but not the absolute position.

However, as you also saw with the iphone demo, the iphone controller lets you move the arm in 3d space as well as closing the hand. It's a bit clunky but we can do a basic teleop demo that way.

I looked more into working with Meta Quest 2, but I couldn't find any out of the box solution that would let us use that. (I would have to build an android app that lives on Meta device and a companion app on linux PC make it communicate together, which i don't plan to do) If we want a better teleop setup, including upper body control and hand open / close, I think we will need to use Pico 4 Ultra enterprise headset (over other headsets because it's what our repo recommends and has the IsaacLab support as well).  
Gabriel Y (Iolani School) — 2/6/26, 6:31 AM  
https://www.instagram.com/reel/DUV6g\_fjB03/  
artificial  
HumanX is a scalable training framework that turns a single monocular video of a person into agile, reusable interaction skills for humanoid robots, without relying on task-specific reward design.

It has two main pieces. XGen retargets the human motion to a robot and expands it into a broad set of physically plausible training data using physic...  
Likes  
314

Instagram  
HumanX, which was recently published (around February 1, 2026\) by researchers from the Hong Kong University of Science and Technology (HKUST) and Shanghai AI Lab.

It is designed to solve one of the hardest problems in robotics: teaching humanoid robots complex, agile interactions (like basketball or football) directly from a single video of a human, without needing to hand-code "reward functions" for every single movement.

The Three Core Components

| HumanX | The Framework | The "full-stack" system that acts as a compiler, turning raw human video into motor control skills for a robot (specifically the Unitree G1). 

| XGen | The Data Generator | It extracts 3D motion from a video and "retargets" it to the robot's body. It then uses physics simulations (like IsaacGym) to create thousands of "what-if" variations to make the training data robust. 

| XMimic | The Brain/Policy | A unified imitation learning system. It uses a "Teacher-Student" setup where a teacher learns with perfect data, and then a student policy is trained to perform the task in the messy real world—even if it's "blind" (using only internal sensors). 

|  
Key Research Insights  
   
Zero-Shot Transfer: The system allows a robot to learn a skill from a video and perform it immediately on physical hardware (like the Unitree G1) without further training.  
Physical Plausibility: Unlike simple video mimicry, XGen ensures the object (like a ball) follows real laws of physics, allowing the robot to perform complex "fadeaway jumpshots" or "football kicks" naturally.

   
8x Improvement: The researchers report an 8-fold increase in "generalization success" compared to previous state-of-the-art methods.

Resources & Repositories  
   
Project Page: wyhuai.github.io/human-x/  
Research Paper: HumanX: Toward Agile and Generalizable Humanoid Interaction Skills from Human Videos (arXiv:2602.02473).

   
Lead Authors: Yinhuai Wang, Qihan Zhao, and Yuen Fui Lau.  
Hardware Used: Primarily the Unitree G1 humanoid robot.  
Gabriel Y (Iolani School) — 2/6/26, 6:39 AM  
https://wyhuai.github.io/human-x/  
HumanX: Toward Agile and Generalizable Humanoid Interaction Skills from Human Videos  
HumanX: Toward Agile and Generalizable Humanoid Interaction Skills ...  
by Yinhuai Wang\*, Qihan Zhao\*, Yuen Fui Lau\*, Runyi Yu, Hok Wai Tsui, Qifeng Chen, Jingbo Wang, Jiangmiao Pang, and Ping Tan  
yosub — 2/6/26, 7:12 AM  
Pretty cool stuff  
Gabriel Y (Iolani School) — 2/8/26, 12:31 PM  
Just FYI, all schools across the state are closed including ours tomorrow because of weather.  
Gabriel Y (Iolani School) — 2/10/26, 8:12 AM  
Lab opened all day today. Elevator is out of order so just use stairs  
Gabriel Y (Iolani School) — 2/10/26, 8:21 AM  
Additionally, I spoke to our main office and  found out that I can just add you as volunteers so you can access the campus and visit the lab anytime you want. 

HR will send you a form to fill out. That's a the state of Hawaii requirement for anyone who visits school campuses.  
If you don't get an email, reach out to Igor or myself and will get you added  
igormolybog — 2/10/26, 9:45 AM  
I'm coming in at around 10 today. See you soon\!  
Gabriel Y (Iolani School) — 2/10/26, 10:30 AM  
Also, if there was any power outage over the storm, the computers probably shut down. So if you still want remote access and you just to turn the computers on let us know.  
igormolybog — 2/10/26, 1:28 PM  
@Brian Shu @Yujin @Pasha   could you please send your robotics project updates async in this chat?

reminder to follow the template:  
What I worked on this past week  
Results / notes  
What I plan to do this week  
Issues / blockers  
   
Brian Shu — Yesterday at 1:53 AM  
What I worked on last time: 

I mainly worked on two components:

The unitree version of isaac sim.  
The VLA model under unitree robotics. (https://github.com/unitreerobotics/unifolm-vla)  
Results / Notes: 

I was able to run and deploy isaac sim and the VLA independently.

What I plan to do next: 

I plan to work on the "bridge" to communicate between these two components. I will specifically be focusing on the DDS protocol and communication layer.

Issues / Blockers: 

None

Note:

I will also update Anton with my current progress, since this is one of the issues he is also facing, and see how we can merge our results.  
GitHub  
GitHub \- unitreerobotics/unifolm-vla  
Contribute to unitreerobotics/unifolm-vla development by creating an account on GitHub.  
Contribute to unitreerobotics/unifolm-vla development by creating an account on GitHub.  
Image  
alestainer — Yesterday at 9:08 AM  
Someone was asking for materials on learning ROS2 \- here's a leetcode style website that gives simple exercises and doesn't require any setup to test your solutions: https://simucode.online/  
SimuCode \- Crack the Robotics Interview  
The LeetCode for Robotics. Practice 190+ ROS2 problems in your browser.  
SimuCode \- Crack the Robotics Interview  
Yujin — Yesterday at 12:47 PM  
What I worked on last time  
    Reproduced Yosub and Anton's implementation (upper body) on MuJoCo.  
    Installed Isaac Lab.  
    Set up a remote connection (used NoMachine for GUI).

Results / notes  
     Completed environment set up.

What I plan to do next time  
    Get familiar with Isaac Lab.  
    Would like to try what Yosub has done — control the robot arm and hand with a phone controller.

Issues / blockers  
      None

Let me know what I can help with.  
Pasha — Yesterday at 1:01 PM  
I was not at Iolani this week 

What I worked on this past week  
pi0 paper;  
went through the BPC paper;  
reached out to authors of it to see if they'd be willing to share code

Results / notes  
presented pi0 visionary, found some good datasets that might be relevant for the challenge

What I plan to do this week  
I am presenting cosmos-reason, will focus on it  
yosub — Yesterday at 3:52 PM  
@alestainer did you at some point run GR00T N1 \+ UniTree G1 on Isaac Sim (or Lab)? I'm trying to do this but i'm not sure how. I'm following this doc, but it just runs an eval and does not open up a sim that i can interact with, so i don't know if it's working and if it does, what kind of sim enviornment is being run.  
https://github.com/NVIDIA/Isaac-GR00T/tree/main/examples/GR00T-WholeBodyControl  
GitHub  
Isaac-GR00T/examples/GR00T-WholeBodyControl at main · NVIDIA/Isaac...  
NVIDIA Isaac GR00T N1.6 \- A Foundation Model for Generalist Robots. \- NVIDIA/Isaac-GR00T  
NVIDIA Isaac GR00T N1.6 \-  A Foundation Model for Generalist Robots. \- NVIDIA/Isaac-GR00T  
Isaac-GR00T/examples/GR00T-WholeBodyCont...  
2 Messages ›  
yosub  
12h ago  
alestainer  
 started a thread: Isaac-GR00T/examples/GR00T-WholeBodyCont.... See all threads. — Yesterday at 6:03 PM  
Gabriel Y (Iolani School) — 7:31 AM  
https://ai.google.dev/edge/mediapipe/solutions/vision/hand\_landmarker  
Google AI for Developers  
Hand landmarks detection guide  |  Google AI Edge  |  Google AI...  
Hand landmarks detection guide  |  Google AI Edge  |  Google AI...  
I've been seeing a bunch of intro ca people post hand tracking examples using camera footage and this from Google.

MrY  
mry808  
Online

Gabriel Y (Iolani School) — 1/29/26, 10:11 AM  
G1 Edu Notes  
Description  
I am currently working with the Unitree G1 Edu (29 DOF) and attempting to use Project GR00T within NVIDIA Isaac Sim as my foundation for training and simulation.

The Issue  
The default Isaac Sim assets and Project GR00T documentation currently only provide a model for the G1 Edu equipped with the standard 3-finger hands. Our hardware configuration utilizes the Inspire RH56DFTP (dexterous 5-finger) hands.

Because the GR00T base model expects the 3-finger configuration, there is a mismatch in the kinematic chain and the observation/action spaces required for reinforcement learning.

Request for Assistance  
I am looking for guidance or existing assets to help bridge this gap:

URDF/USD Assets: Does NVIDIA or Unitree have an official .usd or .urdf file for the G1 29-DOF specifically configured with the Inspire RH56DFTP hands?

GR00T Compatibility: Has anyone successfully updated the GR00T humanoid configuration to support the higher DOF count required for these 5-finger dexterous hands?

Manual Integration: If an official model doesn't exist, are there recommended workflows for swapping the end-effectors in Isaac Sim without breaking the GR00T pre-trained model's coordinate frames?   
Gabriel Y (Iolani School) — 1/29/26, 10:36 AM  
@alestainer https://docs.google.com/document/d/16Z9V\_vw0DwJi32kVrTeIalU8gxe4GgadIq-s\_Iw3Wow/edit?usp=sharing

Can we use this model in Groot?  
Google Docs  
Unitree G1 Inspire Hand Swap  
Yes, you absolutely can use Project GR00T with the Unitree G1 and the Inspire RH56DFTP hands. In fact, as of NVIDIA Isaac Lab 2.3 (released late 2025), this exact configuration is officially supported with dedicated assets and teleoperation retargeting. The reason you likely saw only the 3-finge...  
Image  
How to "Swap" the hands in Simulation  
If you are using the Isaac Lab or GR00T training scripts, you "swap" the hands by changing the Task or the Robot Configuration flag.  
Instead of the standard G1 task, use the specific Inspire-configured task:  
Task Name: Isaac-PickPlace-G1-InspireFTP-Abs-v0 (or Isaac-Reach-G1-Inspire-v0).  
Command Line: If running from a terminal, you can usually specify the robot type:

Bash  
python sim\_main.py \--task Isaac-PickPlace-G1-InspireFTP-Abs-v0 \--robot\_type g129

Note: g129 refers to the 29-DOF version of the G1, which is the standard for the Edu version with dexterous hands.  
Gabriel Y (Iolani School) — 2/2/26, 11:07 PM  
https://raw.githubusercontent.com/mlresearch/v305/main/assets/peri25a/peri25a.pdf  
https://arxiv.org/html/2509.01765v1  
Gabriel Y (Iolani School) — Yesterday at 2:15 PM  
https://github.com/NVlabs/ProtoMotions  
GitHub  
GitHub \- NVlabs/ProtoMotions: ProtoMotions is a GPU-accelerated sim...  
ProtoMotions is a GPU-accelerated simulation and learning framework for training physically simulated digital humans and humanoid robots. \- NVlabs/ProtoMotions  
ProtoMotions is a GPU-accelerated simulation and learning framework for training physically simulated digital humans and humanoid robots. \- NVlabs/ProtoMotions

MrY  
mry808  
Online

Gabriel Y (Iolani School) — 1/27/26, 9:07 AM  
https://github.com/dimensionalos/dimos  
GitHub  
GitHub \- dimensionalOS/dimos: The Dimensional Framework  
The Dimensional Framework. Contribute to dimensionalOS/dimos development by creating an account on GitHub.  
Gabriel Y (Iolani School) — 2/2/26, 11:08 PM  
The information you are looking for comes from a paper titled "Non-conflicting Energy Minimization in Reinforcement Learning based Robot Control," which was presented as an oral presentation at the Conference on Robot Learning (CoRL) 2025\.  
The research was conducted by the Dynamic Robotics and AI Lab (DRAIL) at Oregon State University.  
The Policy: PEGrad  
The "one policy" mentioned in the video refers to a method the authors call PEGrad (Policy Energy Gradient).  
Traditional Reinforcement Learning (RL) often struggles to balance task performance (like walking) with energy efficiency because the two goals can conflict during training. PEGrad solves this by projecting the "energy minimization" gradients onto a space that is orthogonal to the "task success" gradients. This ensures the robot only saves energy in ways that do not hinder its ability to complete the task.  
Key Results  
   
64% Energy Reduction: The method achieved a massive drop in energy usage compared to standard RL baselines.  
Sim-to-Real Success: The policy was trained in simulation and successfully transferred to the Unitree Go2 quadruped robot shown in your image.  
Robustness: The same policy allows the robot to handle different terrains (like grass and pavement) efficiently without needing separate tuning for each.  
Links to the Paper and Resources  
   
OpenReview (Reviews & Discussion): Non-conflicting Energy Minimization in Reinforcement Learning based Robot Control  
arXiv (Preprint): arXiv:2509.01765  
Official PDF (PMLR): Download PDF  
Project Website/Code: You can often find the latest code updates on the Dynamic Robotics and AI Lab website.  
Would you like me to explain how the gradient projection math works in simpler terms?  
[https://arxiv.org/html/2509.01765v1](https://arxiv.org/html/2509.01765v1)

MrY  
mry808  
Online

Gabriel Y (Iolani School) — 1/14/26, 9:16 AM  
https://www.youtube.com/watch?v=OG3b46-TLVQ

https://www.youtube.com/watch?v=3s0Al0kxUuo

https://project-instinct.github.io/deep-whole-body-parkour/

a single policy to perform multiple distinct motions across varied terrestrial features, we demonstrate the non-trivial benefit of integrating perception into the control loop.  
YouTube  
CatBox-zzw  
Project Instinct (Instinct-Level Intelligence)  
Image  
YouTube  
CatBox-zzw  
Deep Whole-body Parkour  
Image  
Deep Whole-body Parkour  
Deformable Neural Radiance Fields creates free-viewpoint portraits (nerfies) from casually captured videos.  
Video to movement data. 

GitHub \- AIM-Intelligence/video2robot: End-to-end pipeline converting generative videos (Veo, Sora) to humanoid robot motions https://share.google/vUqQn5aWtBzBswzdN  
GitHub  
GitHub \- AIM-Intelligence/video2robot: End-to-end pipeline converti...  
End-to-end pipeline converting generative videos (Veo, Sora) to humanoid robot motions \- AIM-Intelligence/video2robot  
GitHub \- AIM-Intelligence/video2robot: End-to-end pipeline converti...  
Gabriel Y (Iolani School) — 1/14/26, 1:12 PM  
Here's AI training data. Again, just for our team's use. Not to be published in a paper or publicly until we get sign off from the individual students and parents if we use any of these in any publications. 

https://drive.google.com/drive/folders/11I9UZfqr\_JanmgzVx3qM0zNF3YzqaEuW  
Google Drive  
igormolybog — 1/15/26, 8:09 AM  
Let's lock the folder with only access for igormolybog@gmail.com 

This is a public discord server, we don't want the link leak anywhere  
Gabriel Y (Iolani School) — 1/15/26, 9:43 AM  
Nikolaev@hawaii.edu  
yosubs@hawaii.edu  
Gabriel Y (Iolani School) — 1/15/26, 11:04 AM  
there is official teleop repo

https://github.com/unitreerobotics/xr\_teleoperate  
GitHub  
GitHub \- unitreerobotics/xr\_teleoperate: This repository implements...  
This repository implements teleoperation of the Unitree humanoid robot using XR Devices. \- unitreerobotics/xr\_teleoperate  
This repository implements teleoperation of the Unitree humanoid robot using XR Devices. \- unitreerobotics/xr\_teleoperate  
Gabriel Y (Iolani School) — 1/16/26, 6:26 PM  
https://www.instagram.com/reel/DSHLGP1iYwS/?igsh=MWY2cGw0djYyaHA1aA==

yonghyun\_\_\_kim  
GD 댄스추는 휴머노이드  
@comeup\_org  
Likes  
67711

Instagram  
Gabriel Y (Iolani School) — 1/17/26, 12:25 PM  
https://www.instagram.com/reel/DTntmo9jEYW/?igsh=MTJ3MzByczAwZ2loMA==

Research team from California got their settings wrong. I will try to look up if there's another way of setting up a kill switch or something with the battery. Let me know if anyone finds workarounds in case a policy goes nuts.

robotics  
Follow US (@ROBOTICS) to learn something NEW everyday 🚀

Footage from California showing a humanoid robot malfunctioning during operation.

What looks like a “rampage” is really a loss of control, a reminder that stability, safeguards, and fail-safes matter just as much as capability as humanoid robots move into public spaces.

\#ai \#arti...

Instagram  
Found the team on Twitter. They're doing AI video to tracking data to SIM to get their animations for their bot. 

https://x.com/i/status/1985430834292383980  
Carlos DP 🤖🇺🇸 (@carlosdponx)  
So, AI video \-\> GVHMR \-\> sim2real motion tracking works, btw

This is a very tricky and dynamic motion that was trained on a video I generated on @fal using Google Veo 3.1 Fast

You can literally do prompt \-\> robot motion now, this is crazy lol  
Image

X•11/3/25, 9:36 AM  
https://x.com/i/status/1996995331549225303

Carlos DP 🤖🇺🇸 (@carlosdponx)  
Did I scoop @ylecun? 😳 https://t.co/vL0w0tXi0U

X•12/5/25, 7:29 AM  
https://x.com/i/status/1995661016550834280

Carlos DP 🤖🇺🇸 (@carlosdponx)  
Refreshing to see a lab release stuff like this, a properly engineered codebase\!

Most of this stuff exists in product groups like ours already. I can only hope labs copy and paste this stuff for now on (and mjlab) instead of like humanoidverse

X•12/1/25, 3:07 PM  
Gabriel Y (Iolani School) — 1/19/26, 5:47 PM  
Molly support: 

Best Regards  
Molly Xia  
Unitree Robotics|Overseas Sales  
Office: \+86-0571-5671 6562   
Email:sales\_xzl@unitree.com  
Mobile/WeChat/ WhatsApp/Skype: \+86-176-2106-8921  
Gabriel Y (Iolani School) — 1/21/26, 8:25 AM  
laikago@unitree.cc  
@alestainer https://inspire-robots.store/products/the-dexterous-hands-rh56dftp?pr\_prod\_strat=e5\_desc\&pr\_rec\_id=5544c6500\&pr\_rec\_pid=8887929274612\&pr\_ref\_pid=7659311694068\&pr\_seq=uniform\&variant=45933596246260

is this the hands we have? 

RH56DFTP  
inspire-robots  
The Dexterous Hands RH56DFTP  
The FTP series integrates 17 tactile sensor in a single hand,which setup allows real-time acquisition of tactile information from various parts, helping to optimize gripping actions and improve operational precision.The FTP series extended its lifespan to over a million, providing long-term reliable support.The fingert  
The Dexterous Hands RH56DFTP  
Gabriel Y (Iolani School) — 1/21/26, 8:38 AM  
@alestainer https://support.unitree.com/home/en/H1\_developer/FTP\_Inspire\_Hand

Here is the hands we have in support. Does it contain what we need?  
igormolybog — 1/21/26, 9:57 AM  
@Gabriel Y (Iolani School) Did you get the fifth PC for the lab?  
Gabriel Y (Iolani School) — 1/21/26, 10:04 AM  
Yes. But I'm still troubleshooting it  
Gabriel Y (Iolani School) — 1/22/26, 8:00 AM  
https://cad.onshape.com/documents/51f2b1c723880a644b5e4295/w/26b9ae2d16dd6818ee2cba50/e/2c03d03c2d68d17d48cc747c  
Onshape  
Sign in to Onshape, the \#1 fastest growing CAD system in the world.  
head model, bracket and clamp  
alestainer — 1/22/26, 9:12 AM  
No, but this is useful too, thank you  
Gabriel Y (Iolani School) — 1/22/26, 12:53 PM  
https://disk.yandex.com/d/YOEhWFYUKNpezA  
Roboverse Go2 files and reference documents. models, docs, photos of parts for me for any repairs.  
Yandex Disk  
Go2  
View and download from Yandex Disk  
Image  
Gabriel Y (Iolani School) — 1/23/26, 4:11 PM  
https://support.unitree.com/home/en/developer/Obtain%20SDK