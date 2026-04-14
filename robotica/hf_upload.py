"""Upload pipeline results to Hugging Face Hub as a dataset."""

from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

from huggingface_hub import HfApi


def upload_results_to_hf(
    repo_id: str,
    results_dir: str,
    rows: list[dict],
) -> bool:
    """Upload .pkl artifacts and metadata to a HF dataset repo.

    Layout on HF Hub:
        phmr/<name>.pkl
        retarget/<name>_<robot>.pkl
        metadata.jsonl

    Returns True on success, False on failure or no files.
    """
    api = HfApi()
    results_path = Path(results_dir)

    try:
        api.create_repo(repo_id, repo_type="dataset", private=True, exist_ok=True)
    except Exception as exc:
        print(f"  [ERROR] Failed to create HF repo: {exc}", file=sys.stderr)
        return False

    print(f"\n═══ Uploading to HF Hub: {repo_id} ═══")

    # Build a temporary staging directory with the desired layout
    with tempfile.TemporaryDirectory(prefix="robotica-hf-") as staging:
        staging_path = Path(staging)
        phmr_dir = staging_path / "phmr"
        retarget_dir = staging_path / "retarget"
        phmr_dir.mkdir()
        retarget_dir.mkdir()

        uploaded_count = 0

        if not results_path.exists():
            print(
                f"  [WARN] Results directory not found: {results_dir}", file=sys.stderr
            )
            return False

        for video_dir in sorted(results_path.iterdir()):
            if not video_dir.is_dir():
                continue
            name = video_dir.name

            # Copy phmr results
            phmr_pkl = video_dir / "phmr_results.pkl"
            if phmr_pkl.exists():
                dst = phmr_dir / f"{name}.pkl"
                dst.write_bytes(phmr_pkl.read_bytes())
                uploaded_count += 1

            # Copy retarget results (all robot variants)
            for retarget_pkl in video_dir.glob("retarget_*.pkl"):
                robot_suffix = retarget_pkl.stem.replace("retarget_", "")
                dst = retarget_dir / f"{name}_{robot_suffix}.pkl"
                dst.write_bytes(retarget_pkl.read_bytes())
                uploaded_count += 1

        # Write metadata.jsonl
        if rows:
            jsonl_path = staging_path / "metadata.jsonl"
            with open(jsonl_path, "w") as f:
                for row in rows:
                    f.write(json.dumps(row, default=str) + "\n")

        if uploaded_count == 0:
            print("  No result files found to upload.")
            return False

        try:
            api.upload_folder(
                repo_id=repo_id,
                repo_type="dataset",
                folder_path=str(staging_path),
                commit_message=f"Update results ({uploaded_count} files)",
            )
        except Exception as exc:
            print(f"  [ERROR] HF upload failed: {exc}", file=sys.stderr)
            return False

        print(
            f"  Uploaded {uploaded_count} files to https://huggingface.co/datasets/{repo_id}"
        )
        return True
