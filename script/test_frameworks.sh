#!/bin/sh
#
# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

SERVER="$1"
OUTPUT_FOLDER="$2"
TEST_NAME="${3:-test}"
TEST_DURATION="${4:-300}"
REQUEST_DELAY="${5:-0.250}"

if [ -z "$SERVER" ] || [ -z "$OUTPUT_FOLDER" ]; then
    echo "Usage: $0 <server_user@host> <output_folder> [test_name] [test_duration] [request_delay]"
    exit 1
fi

SERVER_HOST=$(echo "$SERVER" | sed 's/.*@//')
mkdir -p "$OUTPUT_FOLDER"

MASTER_REMOTE_PATH="/tmp/raplog_${TEST_NAME}.csv"
EVENT_LOG="$OUTPUT_FOLDER/${TEST_NAME}_events.csv"

# Initialize Event Log
echo "timestamp,event,request_num,status" > "$EVENT_LOG"

# --------------------------------------------------
# Pre-Test Setup
# --------------------------------------------------
echo "--- Initializing Hardware State on remote server ---"
ssh "$SERVER" "sh /root/performance.sh && sh /root/noturbo.sh && rm -f $MASTER_REMOTE_PATH"

# --------------------------------------------------
# Function to run a single test
# --------------------------------------------------
run_test() {
    name="$1"
    url="$2"
    ssh_cmds="$3"

    echo ""
    echo "======================================"
    echo "Running test: $name"
    echo "======================================"

    # Run SSH commands safely (sequential commands)
    if [ -n "$ssh_cmds" ]; then
        ssh "$SERVER" "$ssh_cmds"
        sleep 3
    fi

    # Start RAPL logging
    pid=$(ssh "$SERVER" "nohup sh /root/raplog.sh -o $MASTER_REMOTE_PATH -i 1 -t $name </dev/null >/dev/null 2>&1 & echo \$!")

    # Loop requests
    start_time=$(date +%s)
    end_time=$((start_time + TEST_DURATION))
    req_count=0

    while [ "$(date +%s)" -lt "$end_time" ]; do
        req_count=$((req_count + 1))
        ts=$(date +"%Y-%m-%d %H:%M:%S")
        status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url")
        echo "$ts,$name,$req_count,$status" >> "$EVENT_LOG"
        printf "\r%s Request %d | Status: %s" "$name" "$req_count" "$status"
        sleep "$REQUEST_DELAY"
    done
    echo ""

    # Stop RAPL logging
    ssh "$SERVER" "kill $pid"
}

# --------------------------------------------------
# Define all tests (semicolon-separated: name;url;ssh_cmds)
# --------------------------------------------------
# tests="
# baseline;http://${SERVER_HOST}/adrn-3/framework/baseline/hello_pg;rc-service nginx restart; rc-service fcgiwrap restart
# django;http://${SERVER_HOST}/django/hello;rc-service gunicorn restart
# express-app;http://${SERVER_HOST}/express/hello;pm2 restart express-app
# f3;http://${SERVER_HOST}/phpfs/framework/fat-free/;rc-service php-fpm83 restart; rc-service nginx restart
# fastify-app;http://${SERVER_HOST}/fastify/hello;pm2 restart fastify-app
# flask;http://${SERVER_HOST}/flask/hello;rc-service flask-app restart
# javalin;http://${SERVER_HOST}/javalin/hello;rc-service javalin-app restart
# laravel;http://${SERVER_HOST}/phpfs/framework/laravel/public/;rc-service php-fpm83 restart; rc-service nginx restart
# ror;http://${SERVER_HOST}/ror/hello;rc-service puma restart
# sinatra;http://${SERVER_HOST}/sinatra/hello;rc-service sinatra restart
# "
tests="
baseline;http://${SERVER_HOST}/adrn-3/framework/baseline/hello_pg;rc-service nginx restart; rc-service fcgiwrap restart
"

# --------------------------------------------------
# Run all tests
# --------------------------------------------------
echo "$tests" | while IFS= read line; do
    [ -z "$line" ] && continue

    name=$(echo "$line" | cut -d';' -f1 | sed 's/^ *//;s/ *$//')
    url=$(echo "$line" | cut -d';' -f2 | sed 's/^ *//;s/ *$//')
    ssh_cmds=$(echo "$line" | cut -d';' -f3- | sed 's/^ *//;s/ *$//')  # take all remaining fields

    run_test "$name" "$url" "$ssh_cmds"
done

# --------------------------------------------------
# Download Power Log
# --------------------------------------------------
echo ""
echo "======================================"
echo "Downloading Power Log..."
scp "$SERVER:$MASTER_REMOTE_PATH" "$OUTPUT_FOLDER/${TEST_NAME}_rapl.csv"

echo ""
echo "Research Data Collected:"
echo "1. Power Data:  $OUTPUT_FOLDER/${TEST_NAME}_rapl.csv"
echo "2. Event Data:  $EVENT_LOG"
