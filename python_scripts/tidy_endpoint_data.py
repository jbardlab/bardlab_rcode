import argparse
import csv
import os
from io import StringIO

import pandas as pd


def read_lines_with_fallback(input_file):
    """Read text lines using a small set of common encodings."""
    for encoding in ["utf-8", "latin-1", "cp1252"]:
        try:
            with open(input_file, "r", encoding=encoding) as handle:
                return handle.readlines()
        except UnicodeDecodeError:
            continue
    raise ValueError(f"Could not decode file: {input_file}")


def parse_csv(input_file):
    """
    Parse endpoint CSV files that contain a Well/Content table block.

    The parser scans until the header line that starts with "Well,Content,",
    uses that line as table headers, and reads data rows until "Basic settings".
    Output is returned in tidy format (Filename, Well, Content, Channel, Value).
    """
    filename = os.path.basename(input_file)
    lines = read_lines_with_fallback(input_file)

    header_idx = None
    end_idx = None

    for idx, line in enumerate(lines):
        stripped = line.strip()
        if header_idx is None and stripped.startswith("Well,Content,"):
            header_idx = idx
            continue
        if header_idx is not None and stripped.startswith("Basic settings"):
            end_idx = idx
            break

    if header_idx is None:
        raise ValueError('Could not find header line starting with "Well,Content,"')
    if end_idx is None:
        raise ValueError('Could not find terminating line starting with "Basic settings"')

    block_lines = [line for line in lines[header_idx:end_idx] if line.strip()]
    if not block_lines:
        raise ValueError("No table rows found between header and Basic settings")

    reader = csv.reader(StringIO("".join(block_lines)))
    rows = list(reader)
    if not rows:
        raise ValueError("Parsed table block is empty")

    header = [col.strip() for col in rows[0]]
    data_rows = rows[1:]

    df = pd.DataFrame(data_rows, columns=header)

    # Drop trailing empty columns created by trailing commas in the source file.
    drop_cols = [
        col
        for col in df.columns
        if col == "" or col.lower().startswith("unnamed") or df[col].replace("", pd.NA).isna().all()
    ]
    if drop_cols:
        df = df.drop(columns=drop_cols)

    required = {"Well", "Content"}
    if not required.issubset(df.columns):
        raise ValueError(f"Expected columns {required}, found: {list(df.columns)}")

    value_columns = [col for col in df.columns if col not in ["Well", "Content"]]
    if not value_columns:
        raise ValueError("No measurement columns found after Well and Content")

    tidy_df = df.melt(
        id_vars=["Well", "Content"],
        value_vars=value_columns,
        var_name="Channel",
        value_name="Value",
    )

    tidy_df["Value"] = pd.to_numeric(tidy_df["Value"], errors="coerce")
    tidy_df = tidy_df.dropna(subset=["Value"])
    tidy_df.insert(0, "Filename", filename)

    return tidy_df


def main():
    parser = argparse.ArgumentParser(
        description="Convert endpoint plate-reader CSV data to tidy format."
    )
    parser.add_argument("input_csv", help="Path to input CSV file")
    parser.add_argument(
        "--output_csv",
        help="Path to output CSV file (default: input_basename_tidy.csv)",
    )

    args = parser.parse_args()

    if not args.output_csv:
        input_dir = os.path.dirname(args.input_csv)
        input_basename = os.path.splitext(os.path.basename(args.input_csv))[0]
        args.output_csv = os.path.join(input_dir, f"{input_basename}_tidy.csv")

    try:
        df = parse_csv(args.input_csv)
        df = df.sort_values(by=["Filename", "Well", "Content", "Channel"])
        df.to_csv(args.output_csv, index=False)
        print(f"Tidy data saved to {args.output_csv}")
        print(f"Processed {len(df)} data points")
    except Exception as exc:
        print(f"Error processing file: {exc}")


if __name__ == "__main__":
    main()