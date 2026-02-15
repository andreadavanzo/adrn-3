#!/bin/sh
#
# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

import pandas as pd
import matplotlib.pyplot as plt
import os
import glob
import sys

def generate_split_charts(input_dir, output_root, manual_max=None):
    search_path = os.path.join(input_dir, "*_rapl.csv")
    csv_files = glob.glob(search_path)

    if not csv_files:
        print(f"No files matching '*_rapl.csv' found in: {input_dir}")
        return

    # --- Determine Y-Limit Strategy ---
    y_limit = None

    # Mode 1: Global Auto-scale (Scan all files for the max)
    if manual_max and manual_max.lower() == "auto":
        print("Mode: 'auto'. Scanning files for global Y-axis scale...")
        global_max_power = 0
        for file_path in csv_files:
            try:
                df = pd.read_csv(file_path)
                current_max = df['intel-rapl:0_W'].max()
                if current_max > global_max_power:
                    global_max_power = current_max
            except Exception:
                continue
        y_limit = global_max_power * 1.1
        print(f"Global Y-axis limit set to: {y_limit:.2f} Watts")

    # Mode 2: Individual scaling (Do nothing here)
    elif manual_max and manual_max.lower() == "none":
        print("Mode: 'none'. Each plot will use its own local scale.")
        y_limit = None

    # Mode 3: Fixed Numeric Limit
    elif manual_max is not None:
        try:
            y_limit = float(manual_max)
            print(f"Mode: Fixed. Using manual Y-axis limit: {y_limit} Watts")
        except ValueError:
            print(f"Warning: Could not parse '{manual_max}' as a number. Defaulting to local scale.")
            y_limit = None

    if not os.path.exists(output_root):
        os.makedirs(output_root)

    # --- Plotting Phase ---
    num_files = len(csv_files)
    for i, file_path in enumerate(csv_files, 1):
        filename = os.path.basename(file_path)
        print(f"[{i}/{num_files}] Processing: {filename}")

        try:
            df = pd.read_csv(file_path)
        except Exception as e:
            print(f"  >> Error reading {filename}: {e}")
            continue

        file_id = filename.replace("_rapl.csv", "")
        parts = file_id.split("-")
        req_sec = parts[2] if len(parts) > 2 else "unknown"
        duration = parts[3] if len(parts) > 3 else "unknown"

        test_case_dir = os.path.join(output_root, file_id)
        if not os.path.exists(test_case_dir):
            os.makedirs(test_case_dir)

        for tag in df['tag'].unique():
            tag_df = df[df['tag'] == tag].copy()
            tag_df['relative_time'] = range(len(tag_df))

            plt.figure(figsize=(10, 5))
            plt.plot(tag_df['relative_time'], tag_df['intel-rapl:0_W'], color='tab:blue', linewidth=1.5)

            # Apply y_limit only if it's set (Fixed or Auto modes)
            if y_limit is not None:
                plt.ylim(0, y_limit)

            plt.title(f"Framework: {tag} | Load: 1 req every {req_sec}s | Duration: {duration}s")
            plt.xlabel("Time (seconds)")
            plt.ylabel("Power (Watts)")
            plt.grid(True, linestyle='--', alpha=0.6)
            plt.tight_layout()

            save_path = os.path.join(test_case_dir, f"{tag}.png")
            plt.savefig(save_path)
            plt.close()

    print(f"\nDone! Charts saved in: {output_root}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python plot_split_results.py <input_dir> <output_dir> [max_watts|auto|none]")
    else:
        in_dir = sys.argv[1]
        out_dir = sys.argv[2]
        m_max = sys.argv[3] if len(sys.argv) > 3 else "none" # Default to none if not provided
        generate_split_charts(in_dir, out_dir, m_max)