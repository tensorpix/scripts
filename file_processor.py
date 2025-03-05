import argparse
import concurrent.futures
import json
import logging
import os
from pathlib import Path
from typing import Optional

from tqdm import tqdm

logging.basicConfig(level=logging.DEBUG)


def get_file_files(
    directory: Path, extensions: Optional[set[str]] = None
) -> list[Path]:
    """Lists file file paths recursively in a directory.

    Args:
        directory: The root directory to search for file files.
        extensions: A list of file extensions to filter by (default: common file formats).

    Returns:
        A list of file paths matching the given extensions.

    Raises:
        ValueError: If the directory does not exist or is not a directory.
    """
    if not directory.exists() or not directory.is_dir():
        raise ValueError(f"Invalid directory: {directory}")

    if extensions is None:
        extensions = {".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff", ".webp"}

    # convert all extensions to lowercase for case-insensitive comparison
    extensions = {e.lower() for e in extensions}
    paths = [file for file in directory.rglob("*") if file.suffix.lower() in extensions]
    return paths


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input_dir",
        help="Path to the input file directory.",
        required=True,
        type=Path,
    )
    parser.add_argument(
        "--output_dir",
        help="Path to the output directory for JSON result files.",
        type=Path,
    )
    parser.add_argument(
        "--relative_dir",
        help="Relative path directory relative to file file for JSON result files.",
        type=Path,
    )

    parser.add_argument(
        "--num_workers",
        help="Number of workers to use for parallel processing.",
        type=int,
        default=int(os.cpu_count() * 0.8),  # type: ignore
    )
    args = parser.parse_args()

    # Validate that exactly one of output_dir or relative_dir is provided.
    if (args.output_dir is not None) and (args.relative_dir is not None):
        raise ValueError("Only one of --output_dir or --relative_dir must be provided.")
    if (args.output_dir is None) and (args.relative_dir is None):
        raise ValueError("Either --output_dir or --relative_dir must be provided.")
    if not args.input_dir.is_dir():
        raise ValueError("Input directory does not exist or is not a directory.")
    return args


def process_single_file(
    file_path: Path,
    output_dir: Path | None,
    relative_dir: Path,
) -> None:
    if output_dir is not None:
        output_metric_dir = output_dir.resolve()
    else:
        output_metric_dir = Path(file_path.parent, relative_dir).resolve()
    output_metric_dir.mkdir(parents=True, exist_ok=True)

    output_path = output_metric_dir / f"{file_path.name}.json"

    with open(file_path) as f:
        data = f.read()

    with open(output_path, "w") as f:
        json.dump(data, f, indent=4, default=str)


def main() -> None:
    args = parse_args()
    input_dir = Path(args.input_dir)
    output_dir = Path(args.output_dir) if args.output_dir else None
    relative_dir = Path(args.relative_dir)

    files = get_file_files(input_dir)
    logging.info("Found %d files.", len(files))

    max_workers: int = args.num_workers
    futures = list[concurrent.futures.Future]()

    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        for file_path in files:
            future = executor.submit(
                process_single_file,
                file_path=file_path,
                output_dir=output_dir,
                relative_dir=relative_dir,
            )
            futures.append(future)

        for _ in tqdm(
            concurrent.futures.as_completed(futures),
            total=len(futures),
            desc="Processing files",
        ):
            try:
                _.result()
            except Exception as err:
                logging.error("An error occurred in processing: %s", err)