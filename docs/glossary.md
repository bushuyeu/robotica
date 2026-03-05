---
layout: default
title: Glossary
nav_order: 5
---

# Glossary

Quick reference for technical terms used throughout this project. Definitions are kept short and beginner-friendly.

---

**Balance policy** — A learned controller that keeps the robot standing upright. It constantly adjusts the robot's legs and torso to compensate for arm movements or external pushes, much like how you shift your weight when carrying something heavy.

**Checkpoint** — A saved snapshot of a trained machine-learning model's internal state. Loading a checkpoint lets you use the model without re-training it from scratch.

**CUDA** — NVIDIA's programming platform that lets software run computations on a GPU instead of the CPU. Most deep-learning frameworks require CUDA to train and run models efficiently.

**Detectron2** — A computer-vision library from Meta (Facebook) that can detect and segment people and objects in images. In this pipeline it helps locate the person in each video frame.

**Docker** — A tool that packages software and all of its dependencies into an isolated "container." This project uses Docker so that GR00T-WBC can run with the exact libraries it needs without conflicting with the rest of your system.

**DOF (Degrees of Freedom)** — The number of independent ways a robot's joints can move. The Unitree G1 has 29 upper-body DOFs, meaning 29 individual joint angles the pipeline needs to control.

**DROID-SLAM** — An algorithm that estimates how the camera moved while filming. Knowing the camera motion lets the pipeline convert detected poses from camera-relative coordinates into real-world coordinates.

**Elastic band** — A virtual spring in the GR00T-WBC simulator that holds the robot in mid-air so it does not fall while you set things up. You release it (press `9`) once the balance policy is active and the robot is ready to stand on its own.

**GPU (Graphics Processing Unit)** — A specialized processor originally designed for rendering graphics, now widely used to accelerate machine-learning workloads because it can perform many calculations in parallel.

**MuJoCo** — A physics simulator (the name stands for "Multi-Joint dynamics with Contact") used for modeling robots. GR00T-WBC uses MuJoCo to simulate the Unitree G1 so you can test motions before running them on real hardware.

**ONNX** — An open file format for machine-learning models. It lets a model trained in one framework (like PyTorch) run in another runtime, which can be faster or more portable.

**pkl / pickle** — A Python file format (`.pkl`) used to save and load Python objects such as arrays of joint angles or pose data. Most intermediate results in this pipeline are stored as pickle files.

**Retarget / retargeting** — The process of mapping motion from one skeleton to another. A human body and a robot body have different proportions and joint counts, so retargeting adjusts the motion so it looks natural on the target skeleton.

**RL policy (Reinforcement Learning policy)** — A controller trained by trial and error in simulation. The robot tries many actions, gets rewards for staying balanced, and over thousands of episodes learns a policy (a set of rules) for how to move. The balance policy in GR00T-WBC is an RL policy.

**ROS 2** — The Robot Operating System (version 2). Despite the name, it is not a full operating system but a set of libraries and tools for building robot software. GR00T-WBC uses ROS 2 for communication between the control loop and the motion publisher.

**SAM2** — Segment Anything Model 2, a model from Meta that can identify and outline any object in an image or video. Used here to track the person across frames.

**SMPL** — A statistical body model that represents a human body as a mesh of triangles controlled by shape and pose parameters. Think of it as a digital mannequin whose body shape and joint angles you can adjust with numbers.

**SMPL-X** — An extended version of SMPL that also includes a detailed face and individual finger joints. PromptHMR outputs SMPL-X parameters so that hand and facial motion can be captured along with the body.

**Symlink (symbolic link)** — A file-system shortcut that points to another file or folder. This project symlinks body-model files from PromptHMR into GMR so both repos share the same data without duplicating large files on disk.

**Venv (virtual environment)** — An isolated Python installation. Each sub-repo in this project uses its own venv so that conflicting library versions do not interfere with each other.

**ViTPose** — A vision-transformer model that detects 2D body keypoints (shoulders, elbows, wrists, etc.) in an image. The pipeline uses ViTPose-H (the "huge" variant) for accurate keypoint estimation.

**WBC (Whole-Body Control)** — A control approach that coordinates all of a robot's joints at once rather than moving each limb independently. GR00T-WBC uses whole-body control to keep the robot balanced while it replays upper-body motions.
