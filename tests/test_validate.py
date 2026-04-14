from pathlib import Path

import joblib
import numpy as np
import pytest

from robotica.validate import (
    RETARGET_EXPECTED_DOF,
    validate_phmr,
    validate_retarget,
)


def _dump(data: dict, tmp_path: Path, name: str = "artifact.pkl") -> Path:
    path = tmp_path / name
    joblib.dump(data, path)
    return path


def _valid_phmr_person(n_frames: int = 10, shape_dim: int = 10) -> dict:
    return {
        "smplx_world": {
            "pose": np.zeros((n_frames, 165), dtype=np.float32),
            "shape": np.zeros((n_frames, shape_dim), dtype=np.float32),
            "trans": np.zeros((n_frames, 3), dtype=np.float32),
        }
    }


def _valid_retarget(n_frames: int = 30) -> dict:
    return {
        "fps": 30.0,
        "dof_pos": np.zeros((n_frames, RETARGET_EXPECTED_DOF), dtype=np.float32),
    }


# ── validate_phmr ──────────────────────────────────────────────────────────


def test_phmr_missing_file_reports_error(tmp_path: Path) -> None:
    errors = validate_phmr(tmp_path / "nope.pkl")
    assert errors and "file not found" in errors[0]


def test_phmr_valid_people_dict_passes(tmp_path: Path) -> None:
    path = _dump({"people": {0: _valid_phmr_person()}}, tmp_path)
    assert validate_phmr(path) == []


def test_phmr_accepts_shape_dim_16(tmp_path: Path) -> None:
    # GMR pads shape to 16, so both 10 and 16 must validate.
    path = _dump({"people": {0: _valid_phmr_person(shape_dim=16)}}, tmp_path)
    assert validate_phmr(path) == []


def test_phmr_rejects_nan_values(tmp_path: Path) -> None:
    person = _valid_phmr_person()
    person["smplx_world"]["pose"][0, 0] = np.nan
    path = _dump({"people": {0: person}}, tmp_path)
    errors = validate_phmr(path)
    assert any("NaN" in e or "Inf" in e for e in errors)


def test_phmr_rejects_empty_people(tmp_path: Path) -> None:
    path = _dump({"people": {}}, tmp_path)
    errors = validate_phmr(path)
    assert errors and "no people" in errors[0]


def test_phmr_fallback_to_top_level_person_keys(tmp_path: Path) -> None:
    # Older format: top-level dict keyed by person ID, no 'people' wrapper.
    path = _dump({0: _valid_phmr_person()}, tmp_path)
    assert validate_phmr(path) == []


def test_phmr_rejects_inconsistent_frame_counts(tmp_path: Path) -> None:
    person = _valid_phmr_person(n_frames=10)
    person["smplx_world"]["trans"] = np.zeros((5, 3), dtype=np.float32)
    path = _dump({"people": {0: person}}, tmp_path)
    errors = validate_phmr(path)
    assert any("inconsistent frame counts" in e for e in errors)


# ── validate_retarget ──────────────────────────────────────────────────────


def test_retarget_valid_passes(tmp_path: Path) -> None:
    path = _dump(_valid_retarget(), tmp_path)
    errors, warnings = validate_retarget(path)
    assert errors == []
    assert warnings == []


def test_retarget_missing_required_keys(tmp_path: Path) -> None:
    path = _dump({"fps": 30.0}, tmp_path)  # missing dof_pos
    errors, _ = validate_retarget(path)
    assert errors and "missing keys" in errors[0]


def test_retarget_rejects_nonpositive_fps(tmp_path: Path) -> None:
    data = _valid_retarget()
    data["fps"] = 0
    path = _dump(data, tmp_path)
    errors, _ = validate_retarget(path)
    assert any("fps must be positive" in e for e in errors)


def test_retarget_rejects_wrong_dof_count(tmp_path: Path) -> None:
    data = _valid_retarget()
    data["dof_pos"] = np.zeros((10, 23), dtype=np.float32)  # wrong DOF
    path = _dump(data, tmp_path)
    errors, _ = validate_retarget(path)
    assert any(f"{RETARGET_EXPECTED_DOF}" in e for e in errors)


def test_retarget_rejects_nan(tmp_path: Path) -> None:
    data = _valid_retarget()
    data["dof_pos"][0, 0] = np.nan
    path = _dump(data, tmp_path)
    errors, _ = validate_retarget(path)
    assert any("NaN" in e or "Inf" in e for e in errors)


def test_retarget_warns_on_joint_limit_violation(tmp_path: Path) -> None:
    # Shoulder roll outside self-collision-safe range triggers warning, not error.
    data = _valid_retarget()
    data["dof_pos"][:, 15] = 3.0  # left_shoulder_roll max is 2.2515
    path = _dump(data, tmp_path)
    errors, warnings = validate_retarget(path)
    assert errors == []
    assert any("left_shoulder_roll" in w for w in warnings)


def test_retarget_rejects_zero_frames(tmp_path: Path) -> None:
    data = _valid_retarget(n_frames=0)
    path = _dump(data, tmp_path)
    errors, _ = validate_retarget(path)
    assert any("zero frames" in e for e in errors)
