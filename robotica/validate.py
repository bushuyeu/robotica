"""Validate pipeline artifacts at stage boundaries.

Usage:
    python -m robotica.validate phmr   results/<video>/phmr_results.pkl
    python -m robotica.validate retarget results/<video>/retarget_unitree_g1.pkl

Exit code 0 = valid, 1 = invalid (blocks .done marker in Justfile).
"""

from __future__ import annotations

import sys
from pathlib import Path

import joblib
import numpy as np


# ── PromptHMR output contract ──────────────────────────────────────────────

PHMR_REQUIRED_WORLD_KEYS = {"pose", "shape", "trans"}
PHMR_EXPECTED_SHAPES = {
    "pose": (None, 165),   # (N, 165) axis-angle
    "shape": (None, 10),   # (N, 10) beta coefficients  (GMR pads to 16 if needed)
    "trans": (None, 3),    # (N, 3) root translation
}


def validate_phmr(path: str | Path) -> list[str]:
    """Validate PromptHMR results.pkl. Returns list of errors (empty = valid)."""
    path = Path(path)
    errors: list[str] = []

    if not path.exists():
        return [f"file not found: {path}"]

    try:
        data = joblib.load(path)
    except Exception as exc:
        return [f"failed to load pkl: {exc}"]

    if not isinstance(data, dict):
        return [f"expected dict, got {type(data).__name__}"]

    # Find people dict — PromptHMR nests under 'people' key with track IDs
    people = data.get("people", {})
    if not isinstance(people, dict) or len(people) == 0:
        # Fall back: top-level might be keyed by person ID directly (older format)
        people = {k: v for k, v in data.items() if isinstance(v, dict) and "smplx_world" in v}
        if len(people) == 0:
            errors.append("no people found in results (need 'people' dict with 'smplx_world' data)")
            return errors

    for pid, pdata in people.items():
        prefix = f"person {pid}"
        if not isinstance(pdata, dict):
            errors.append(f"{prefix}: expected dict, got {type(pdata).__name__}")
            continue

        world = pdata.get("smplx_world")
        if world is None:
            errors.append(f"{prefix}: missing 'smplx_world' key")
            continue

        missing = PHMR_REQUIRED_WORLD_KEYS - set(world.keys())
        if missing:
            errors.append(f"{prefix}: smplx_world missing keys: {missing}")
            continue

        frame_counts = []
        for key, expected_shape in PHMR_EXPECTED_SHAPES.items():
            arr = np.asarray(world[key])
            # Check dimensionality
            if arr.ndim != 2:
                errors.append(f"{prefix}: smplx_world.{key} expected 2D, got {arr.ndim}D")
                continue
            # Check second dimension (first is N frames, variable)
            if expected_shape[1] is not None and arr.shape[1] != expected_shape[1]:
                # shape can be 10 or 16, GMR handles both
                if key == "shape" and arr.shape[1] in (10, 16):
                    pass
                else:
                    errors.append(f"{prefix}: smplx_world.{key} shape {arr.shape}, expected (N, {expected_shape[1]})")
            # Check for NaN/Inf
            nan_count = np.sum(~np.isfinite(arr))
            if nan_count > 0:
                errors.append(f"{prefix}: smplx_world.{key} has {nan_count} NaN/Inf values")
            frame_counts.append(arr.shape[0])

        # Check frame counts are consistent across keys
        if len(set(frame_counts)) > 1:
            errors.append(f"{prefix}: inconsistent frame counts across keys: {dict(zip(PHMR_EXPECTED_SHAPES.keys(), frame_counts))}")
        elif frame_counts and frame_counts[0] == 0:
            errors.append(f"{prefix}: zero frames")

    return errors


# ── Retarget output contract ───────────────────────────────────────────────

RETARGET_REQUIRED_KEYS = {"fps", "dof_pos"}
RETARGET_EXPECTED_DOF = 29  # Unitree G1 29-DOF

# Self-collision-safe joint limits (matching publisher's SELF_COLLISION_SAFE_LIMITS + URDF)
# Order matches DEFAULT_DOF_NAMES_29 in the publisher.
JOINT_LIMITS_29 = {
    # (index, name, min, max)
    15: ("left_shoulder_roll", -0.75, 2.2515),
    22: ("right_shoulder_roll", -2.2515, 0.75),
}


def validate_retarget(path: str | Path) -> tuple[list[str], list[str]]:
    """Validate GMR retarget pkl. Returns (errors, warnings).

    Errors = hard fail (corrupt data). Warnings = will be clamped at playback.
    """
    path = Path(path)
    errors: list[str] = []
    warnings: list[str] = []

    if not path.exists():
        return [f"file not found: {path}"], []

    try:
        data = joblib.load(path)
    except Exception as exc:
        return [f"failed to load pkl: {exc}"], []

    if not isinstance(data, dict):
        return [f"expected dict, got {type(data).__name__}"], []

    missing = RETARGET_REQUIRED_KEYS - set(data.keys())
    if missing:
        errors.append(f"missing keys: {missing}")
        return errors, []

    # Validate fps
    fps = data["fps"]
    if not isinstance(fps, (int, float)) or fps <= 0:
        errors.append(f"fps must be positive number, got {fps!r}")

    # Validate dof_pos
    dof_pos = np.asarray(data["dof_pos"])
    if dof_pos.ndim != 2:
        errors.append(f"dof_pos expected 2D, got {dof_pos.ndim}D shape {dof_pos.shape}")
        return errors, []

    n_frames, n_dof = dof_pos.shape
    if n_frames == 0:
        errors.append("dof_pos has zero frames")
        return errors, []

    if n_dof != RETARGET_EXPECTED_DOF:
        errors.append(f"dof_pos has {n_dof} DOFs, expected {RETARGET_EXPECTED_DOF}")

    # Check for NaN/Inf (hard fail — corrupt data)
    nan_count = int(np.sum(~np.isfinite(dof_pos)))
    if nan_count > 0:
        nan_frames = int(np.sum(np.any(~np.isfinite(dof_pos), axis=1)))
        errors.append(f"dof_pos has {nan_count} NaN/Inf values across {nan_frames} frames")

    # Check self-collision-safe joint limits (warning — publisher will clamp)
    for idx, (name, lo, hi) in JOINT_LIMITS_29.items():
        if idx >= n_dof:
            continue
        col = dof_pos[:, idx]
        violations = int(np.sum((col < lo) | (col > hi)))
        if violations > 0:
            actual_min = float(np.min(col))
            actual_max = float(np.max(col))
            warnings.append(
                f"{name} (DOF {idx}): {violations}/{n_frames} frames outside self-collision-safe "
                f"range [{lo:.2f}, {hi:.2f}] (actual [{actual_min:.3f}, {actual_max:.3f}]) "
                f"— will be clamped at playback"
            )

    # Validate optional arrays if present
    for key, expected_cols in [("root_pos", 3), ("root_rot", 4)]:
        if key in data:
            arr = np.asarray(data[key])
            if arr.ndim != 2 or arr.shape != (n_frames, expected_cols):
                errors.append(f"{key} shape {arr.shape}, expected ({n_frames}, {expected_cols})")
            nan_count = int(np.sum(~np.isfinite(arr)))
            if nan_count > 0:
                errors.append(f"{key} has {nan_count} NaN/Inf values")

    return errors, warnings


# ── CLI entry point ────────────────────────────────────────────────────────

VALIDATORS = {
    "phmr": validate_phmr,
    "retarget": validate_retarget,
}


def main() -> int:
    if len(sys.argv) != 3 or sys.argv[1] not in VALIDATORS:
        print(f"Usage: python -m robotica.validate <{'|'.join(VALIDATORS)}> <path>", file=sys.stderr)
        return 1

    stage = sys.argv[1]
    path = sys.argv[2]
    result = VALIDATORS[stage](path)

    # phmr returns list[str], retarget returns (list[str], list[str])
    if isinstance(result, tuple):
        errors, warnings = result
    else:
        errors, warnings = result, []

    if warnings:
        print(f"[WARN] {stage} validation warnings for {path}:", file=sys.stderr)
        for w in warnings:
            print(f"  - {w}", file=sys.stderr)

    if errors:
        print(f"[FAIL] {stage} validation failed for {path}:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1

    print(f"[OK] {stage} validation passed: {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
