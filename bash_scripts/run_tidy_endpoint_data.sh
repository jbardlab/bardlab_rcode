#!/bin/bash
# Variables
REPO_PATH="/Users/jbard/Library/CloudStorage/SynologyDrive-home/repos/bardlab_rcode/"  # Path to the repository
SCRIPT_PATH="${REPO_PATH}/python_scripts/tidy_endpoint_data.py"  # Location of tidy_endpoint_data.py
PIXI_TOML_LOCATION="${REPO_PATH}/pixi.toml"  # Location of pixi.toml
TARGET_FOLDER="${REPO_PATH}/bigdata/test_abs"  # Folder containing endpoint CSV files

# Process each CSV file in the target folder
echo "Processing CSV files in $TARGET_FOLDER..."
shopt -s nocasematch
for csv_file in "$TARGET_FOLDER"/*.CSV "$TARGET_FOLDER"/*.csv; do
    if [ -f "$csv_file" ]; then
        # Skip files ending with _tidy.csv (case insensitive check)
        if [[ "$csv_file" != *"_tidy.csv" ]]; then
            echo "Processing: $csv_file"
            pixi run --manifest-path "${PIXI_TOML_LOCATION}" python "${SCRIPT_PATH}" "$csv_file"
        else
            echo "Skipping: $csv_file (already tidied)"
        fi
    fi
done
shopt -u nocasematch

echo "All CSV files processed."