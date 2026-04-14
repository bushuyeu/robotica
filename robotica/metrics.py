"""Extract metadata and metrics from pipeline artifacts."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

import joblib
import numpy as np


def _safe_float(val: float) -> float | None:
    """Return val if finite, else None."""
    if np.isfinite(val):
        return round(float(val), 4)
    return None


def extract_video_metadata(path: str | Path) -> dict:
    """Use ffprobe to extract fps, resolution, and duration from a video file."""
    path = Path(path)
    if not path.exists():
        return {"error": f"file not found: {path}"}

    cmd = [
        "ffprobe",
        "-v",
        "quiet",
        "-print_format",
        "json",
        "-show_format",
        "-show_streams",
        str(path),
    ]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        probe = json.loads(result.stdout)
    except (subprocess.TimeoutExpired, json.JSONDecodeError, FileNotFoundError):
        return {"error": "ffprobe failed or not installed"}

    video_stream = next(
        (s for s in probe.get("streams", []) if s.get("codec_type") == "video"),
        None,
    )
    meta: dict = {"file_size_mb": round(path.stat().st_size / 1e6, 2)}
    if video_stream:
        meta["width"] = int(video_stream.get("width", 0))
        meta["height"] = int(video_stream.get("height", 0))
        # Parse fps from r_frame_rate (e.g. "30/1")
        rfr = video_stream.get("r_frame_rate", "0/1")
        try:
            if "/" in rfr:
                num, den = rfr.split("/")
            else:
                num, den = rfr, "1"
            meta["fps"] = round(int(num) / max(int(den), 1), 2)
        except (ValueError, ZeroDivisionError):
            meta["fps"] = 0

    fmt = probe.get("format", {})
    if "duration" in fmt:
        try:
            meta["duration_s"] = round(float(fmt["duration"]), 2)
        except (ValueError, TypeError):
            pass

    return meta


def extract_phmr_metrics(pkl_path: str | Path) -> dict:
    """Load phmr_results.pkl and return frame count, num_people, file size."""
    pkl_path = Path(pkl_path)
    if not pkl_path.exists():
        return {"error": f"file not found: {pkl_path}"}

    try:
        data = joblib.load(pkl_path)
    except Exception as exc:
        return {"error": f"failed to load pkl: {exc}"}

    metrics: dict = {
        "file_size_mb": round(pkl_path.stat().st_size / 1e6, 2),
    }

    # PromptHMR results are typically a dict with person IDs as keys
    if isinstance(data, dict):
        metrics["num_people"] = len(data)
        # Try to get frame count from the first person's data
        for _pid, pdata in data.items():
            if isinstance(pdata, dict):
                # Look for common keys that indicate frame count
                for key in ("body_pose", "global_orient", "smplx_params"):
                    if key in pdata:
                        val = pdata[key]
                        if hasattr(val, "shape"):
                            metrics["frame_count"] = int(val.shape[0])
                            break
                if "frame_count" in metrics:
                    break
            elif hasattr(pdata, "shape"):
                metrics["frame_count"] = int(pdata.shape[0])
                break
    elif isinstance(data, (list, np.ndarray)):
        metrics["frame_count"] = len(data)

    return metrics


def _extract_dof_stats(arr: np.ndarray, metrics: dict) -> None:
    """Extract DOF statistics from an array, handling NaN/Inf."""
    metrics["frame_count"] = int(arr.shape[0])
    if arr.ndim >= 2:
        metrics["dof_count"] = int(arr.shape[1])
        metrics["dof_mean"] = _safe_float(np.nanmean(arr))
        metrics["dof_std"] = _safe_float(np.nanstd(arr))
        metrics["dof_min"] = _safe_float(np.nanmin(arr))
        metrics["dof_max"] = _safe_float(np.nanmax(arr))


def extract_retarget_metrics(pkl_path: str | Path) -> dict:
    """Load retarget.pkl and return frame count, DOF stats, file size."""
    pkl_path = Path(pkl_path)
    if not pkl_path.exists():
        return {"error": f"file not found: {pkl_path}"}

    try:
        data = joblib.load(pkl_path)
    except Exception as exc:
        return {"error": f"failed to load pkl: {exc}"}

    metrics: dict = {
        "file_size_mb": round(pkl_path.stat().st_size / 1e6, 2),
    }

    # Retarget output is typically a numpy array of shape (frames, dofs)
    if isinstance(data, np.ndarray):
        _extract_dof_stats(data, metrics)
    elif isinstance(data, dict):
        # Some retarget formats use dicts
        for key in ("joint_positions", "q", "positions", "dof_pos"):
            if key in data and hasattr(data[key], "shape"):
                _extract_dof_stats(np.asarray(data[key]), metrics)
                break

    return metrics
