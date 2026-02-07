#!/bin/sh
#
# Audax Development Research Notes - 2
# https://github.com/andreadavanzo/adrn-2
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo
#
# Master Runner Script for Sequential Testing

# Check if we have exactly 4 arguments
if [ "$#" -ne 4 ]; then
  echo "Error: Missing arguments."
  echo "Usage: $0 <server> <folder> <duration> <\"delay1 delay2 ...\">"
  echo "Example: $0 root@edsger /root/adrn-2 300 \"0.010 0.500 1.000\""
  exit 1
fi

SERVER="$1"
DEST_FOLDER="$2"
DURATION="$3"
DELAYS="$4"  # The list of delays passed as a quoted string

echo "============================================================"
echo " BATCH CONFIGURATION"
echo " Server:   $SERVER"
echo " Folder:   $DEST_FOLDER"
echo " Duration: $DURATION sec"
echo " Delays:   $DELAYS"
echo "============================================================"

for delay in $DELAYS; do
  iteration=1
  while [ $iteration -le 3 ]; do

    TEST_NAME="test-${DURATION}-${delay}-${iteration}"

    echo ""
    echo ">>> [START] $TEST_NAME"

    # Execute the framework test script
    sh test_frameworks.sh "$SERVER" "$DEST_FOLDER" "$TEST_NAME" "$DURATION" "$delay"

    # Quick post-run check of the baseline stability
    CSV_FILE="${DEST_FOLDER}/${TEST_NAME}_rapl.csv"
    if [ -f "$CSV_FILE" ]; then
        echo ">>> [DATA] Baseline Summary for $TEST_NAME:"
        awk -F, '$18 == "baseline" {
            count++;
            if(count > 1) {
                sum+=$3;
                if(min=="" || $3<min) min=$3;
                if(max=="" || $3>max) max=$3
            }
        }
        END {
            if(count > 1)
                printf "    Min: %.3fW | Max: %.3fW | Avg: %.3fW\n", min, max, sum/(count-1);
        }' "$CSV_FILE"
    fi

    echo ">>> [WAIT] 30s"
    sleep 30

    iteration=$((iteration + 1))
  done
done

echo "============================================================"
echo " ALL BATCHES COMPLETE"
echo "============================================================"