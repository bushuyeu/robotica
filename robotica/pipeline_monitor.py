"""Monitored pipeline runner — wraps Justfile recipes with wandb logging."""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import time
from pathlib import Path

from dotenv import load_dotenv

from robotica.metrics import (
    extract_phmr_metrics,
    extract_retarget_metrics,
    extract_video_metadata,
)

# Per-recipe timeout: 2 hours (PromptHMR can be slow on long videos)
_RECIPE_TIMEOUT = 7200


def _run_recipe(
    recipe: str, args: list[str] | None = None
) -> tuple[str, float, bool, bool]:
    """Run a just recipe, return (stdout, elapsed_seconds, skipped, failed)."""
    cmd = ["just", recipe] + (args or [])
    start = time.monotonic()
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=_RECIPE_TIMEOUT
        )
    except subprocess.TimeoutExpired:
        elapsed = time.monotonic() - start
        print(f"  [ERROR] {recipe} timed out after {_RECIPE_TIMEOUT}s", file=sys.stderr)
        return "", elapsed, False, True
    elapsed = time.monotonic() - start

    output = result.stdout + result.stderr
    skipped = "[SKIP]" in output
    failed = result.returncode != 0 and not skipped

    if failed:
        print(f"  [ERROR] {recipe} failed (rc={result.returncode})", file=sys.stderr)
        print(output, file=sys.stderr)

    return output, elapsed, skipped, failed


def _process_video(
    video_path: str,
    robot: str,
    results_dir: str,
) -> dict:
    """Run phmr-run + gmr-retarget for one video, return row dict."""
    name = Path(video_path).stem
    row: dict = {"video": name, "status": "ok"}

    # Video metadata
    video_meta = extract_video_metadata(video_path)
    row["video_duration_s"] = video_meta.get("duration_s", 0)
    row["video_fps"] = video_meta.get("fps", 0)
    row["video_resolution"] = (
        f"{video_meta.get('width', '?')}x{video_meta.get('height', '?')}"
    )

    # Stage 1: PromptHMR
    print(f"  [1/2] PromptHMR → {name}")
    phmr_out, phmr_time, phmr_skip, phmr_fail = _run_recipe("phmr-run", [video_path])
    row["phmr_duration_s"] = round(phmr_time, 1)
    row["phmr_skipped"] = phmr_skip

    if phmr_fail or "[ERROR]" in phmr_out:
        row["status"] = "phmr_error"
        return row

    # Extract PHMR metrics
    phmr_pkl = Path(results_dir) / name / "phmr_results.pkl"
    phmr_metrics = extract_phmr_metrics(phmr_pkl)
    row["phmr_frames"] = phmr_metrics.get("frame_count", 0)
    row["phmr_people"] = phmr_metrics.get("num_people", 0)
    row["phmr_size_mb"] = phmr_metrics.get("file_size_mb", 0)

    # Stage 2: GMR retarget
    print(f"  [2/2] GMR retarget → {name} ({robot})")
    gmr_out, gmr_time, gmr_skip, gmr_fail = _run_recipe(
        "gmr-retarget", [video_path, robot]
    )
    row["gmr_duration_s"] = round(gmr_time, 1)
    row["gmr_skipped"] = gmr_skip

    if gmr_fail or "[ERROR]" in gmr_out:
        row["status"] = "gmr_error"
        return row

    # Extract retarget metrics
    retarget_pkl = Path(results_dir) / name / f"retarget_{robot}.pkl"
    retarget_metrics = extract_retarget_metrics(retarget_pkl)
    row["retarget_frames"] = retarget_metrics.get("frame_count", 0)
    row["retarget_dofs"] = retarget_metrics.get("dof_count", 0)
    row["retarget_size_mb"] = retarget_metrics.get("file_size_mb", 0)
    row["dof_mean"] = retarget_metrics.get("dof_mean", 0)
    row["dof_std"] = retarget_metrics.get("dof_std", 0)
    row["dof_min"] = retarget_metrics.get("dof_min", 0)
    row["dof_max"] = retarget_metrics.get("dof_max", 0)

    return row


def run_monitored(
    videos: list[str],
    robot: str = "unitree_g1",
    wandb_project: str = "robotica",
    no_wandb: bool = False,
    hf_upload: bool = False,
    hf_repo: str = "bushuyeu/robotica-results",
    drive_sync: bool = False,
) -> list[dict]:
    """Run the pipeline on a list of videos with optional wandb + HF logging."""
    load_dotenv()
    results_dir = os.environ.get("RESULTS_DIR", "results")

    # Optional: sync from Drive first
    if drive_sync:
        print("═══ Syncing from Google Drive ═══")
        _run_recipe("drive-sync")
        print()

    # Init wandb
    wandb_run = None
    if not no_wandb:
        try:
            import wandb

            wandb_run = wandb.init(
                project=wandb_project,
                config={"robot": robot, "num_videos": len(videos)},
                tags=["pipeline", robot],
            )
        except Exception as exc:
            print(f"  [WARN] wandb init failed: {exc}", file=sys.stderr)
            print("  Continuing without wandb logging.", file=sys.stderr)

    batch_start = time.monotonic()
    rows: list[dict] = []

    for i, video in enumerate(videos, 1):
        print(f"\n═══ [{i}/{len(videos)}] {Path(video).stem} ═══")
        row = _process_video(video, robot, results_dir)
        rows.append(row)

    batch_duration = time.monotonic() - batch_start

    # Compute summary stats
    newly_processed = sum(
        1
        for r in rows
        if r["status"] == "ok"
        and not r.get("phmr_skipped")
        and not r.get("gmr_skipped")
    )
    skipped = sum(
        1 for r in rows if r.get("phmr_skipped") and r.get("gmr_skipped")
    )
    errors = sum(1 for r in rows if r["status"] != "ok")

    print("\n═══ Batch Summary ═══")
    print(f"  Total videos:     {len(rows)}")
    print(f"  Newly processed:  {newly_processed}")
    print(f"  Skipped (cached): {skipped}")
    print(f"  Errors:           {errors}")
    print(f"  Total time:       {batch_duration:.1f}s")

    # Log to wandb
    if wandb_run is not None:
        import wandb

        wandb.log(
            {
                "batch/total_videos": len(rows),
                "batch/newly_processed": newly_processed,
                "batch/skipped": skipped,
                "batch/errors": errors,
                "batch/total_duration_s": round(batch_duration, 1),
            }
        )

        # Build results table
        columns = [
            "video",
            "status",
            "phmr_duration_s",
            "phmr_skipped",
            "phmr_frames",
            "phmr_people",
            "phmr_size_mb",
            "gmr_duration_s",
            "gmr_skipped",
            "retarget_frames",
            "retarget_dofs",
            "retarget_size_mb",
            "dof_mean",
            "dof_std",
            "dof_min",
            "dof_max",
            "video_duration_s",
            "video_fps",
            "video_resolution",
        ]
        table = wandb.Table(columns=columns)
        for r in rows:
            table.add_data(*[r.get(c, "") for c in columns])
        wandb.log({"results_table": table})

        url = wandb_run.url
        wandb_run.finish()
        print(f"  wandb run: {url}")

    # Optional HF upload
    if hf_upload:
        from robotica.hf_upload import upload_results_to_hf

        success = upload_results_to_hf(hf_repo, results_dir, rows)
        if not success:
            print("  [WARN] HF upload returned no files.", file=sys.stderr)

    return rows


def _collect_videos(args: argparse.Namespace) -> list[str]:
    """Resolve video list from CLI args."""
    load_dotenv()

    if args.video:
        return [args.video]

    # Batch mode: all videos in VIDEO_DIR
    video_dir = os.environ.get("VIDEO_DIR", "data/videos")
    video_path = Path(video_dir)
    if not video_path.exists():
        print(f"Video directory does not exist: {video_dir}", file=sys.stderr)
        sys.exit(1)

    exts = (".mp4", ".avi", ".mov", ".mkv")
    videos = sorted(
        str(p) for p in video_path.iterdir() if p.suffix.lower() in exts
    )
    if not videos:
        print(f"No videos found in {video_dir}", file=sys.stderr)
        sys.exit(1)
    return videos


def main() -> None:
    parser = argparse.ArgumentParser(description="Monitored robotica pipeline")
    parser.add_argument("--video", help="Single video path (batch mode if omitted)")
    parser.add_argument("--robot", default="unitree_g1", help="Target robot")
    parser.add_argument(
        "--wandb-project", default="robotica", help="wandb project name"
    )
    parser.add_argument(
        "--no-wandb", action="store_true", help="Disable wandb logging"
    )
    parser.add_argument(
        "--hf-upload", action="store_true", help="Upload results to HF Hub"
    )
    parser.add_argument(
        "--hf-repo", default="bushuyeu/robotica-results", help="HF dataset repo"
    )
    parser.add_argument(
        "--drive-sync", action="store_true", help="Sync from Google Drive first"
    )
    args = parser.parse_args()

    videos = _collect_videos(args)
    run_monitored(
        videos=videos,
        robot=args.robot,
        wandb_project=args.wandb_project,
        no_wandb=args.no_wandb,
        hf_upload=args.hf_upload,
        hf_repo=args.hf_repo,
        drive_sync=args.drive_sync,
    )


if __name__ == "__main__":
    main()
