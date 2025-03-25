#!/bin/bash
# Variables
REPO_PATH="/Users/jbard/Library/CloudStorage/OneDrive-TexasA&MUniversity/repos/bardlab_rcode"  # Path to the repository
SCRIPT_PATH="${REPO_PATH}/python_scripts/tidy_matrix_scan.py"  # Location of tidy_matrix_scan.py
PIXI_TOML_LOCATION="${REPO_PATH}/pixi.toml"  # Location of pixi.toml
TARGET_FOLDER="/Users/jbard/Library/CloudStorage/OneDrive-TexasA&MUniversity/repos/bardlab_rcode/example_data/matrix_scan"  # Folder containing CSV files

# Process each CSV file in the target folder
echo "Processing CSV files in $TARGET_FOLDER..."
for csv_file in "$TARGET_FOLDER"/*.CSV "$TARGET_FOLDER"/*.csv; do
    if [ -f "$csv_file" ]; then
        echo "Processing: $csv_file"
        pixi run --manifest-path "${PIXI_TOML_LOCATION}" python "${SCRIPT_PATH}" "$csv_file"
    fi
done

echo "All CSV files processed."