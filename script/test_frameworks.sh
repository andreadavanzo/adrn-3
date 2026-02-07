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
echo ""
echo "======================================"
echo "--- Initializing Hardware State on remote server ---"
ssh -n "$SERVER" "sh /root/performance.sh && sh /root/noturbo.sh && rm -f $MASTER_REMOTE_PATH"
echo ""

# --------------------------------------------------
# Pre-Test Setup: Kill EVERYTHING before starting
# --------------------------------------------------
echo "--- Cleaning up remote environment ---"
ssh -n "$SERVER" "pkill -f raplog.sh; fuser -k 80/tcp; rm -f $MASTER_REMOTE_PATH"

run_test() {
    name=$1
    url=$2
    start_cmds=$3
    stop_cmds=$4

    echo "--- Starting Service: $name ---"
    if [ -n "$start_cmds" ]; then
        ssh -n "$SERVER" "$start_cmds"
        sleep 5
    fi

    # 1. START LOGGER (Using a dedicated Tag for cleanup)
    ssh -n "$SERVER" "nohup sh /root/raplog.sh -o $MASTER_REMOTE_PATH -i 1 -t $name >/dev/null 2>&1 &"
    sleep 2 # Let it initialize

    # 2. RUN TIME-BASED LOOP
    req_count=0
    start_time=$(date +%s)
    end_time=$((start_time + TEST_DURATION))

    while [ $(date +%s) -lt $end_time ]; do
        req_count=$((req_count + 1))
        ts=$(date +"%Y-%m-%d %H:%M:%S")
        status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 "$url")

        echo "$ts,$name,$req_count,$status" >> "$EVENT_LOG"
        printf "\r--- %s | Req: %d | Stat: %s | Time Left: %ds   " \
               "$name" "$req_count" "$status" "$((end_time - $(date +%s)))"

        sleep "$REQUEST_DELAY"
    done
    echo ""

    # 3. STOP SERVICE
    if [ -n "$stop_cmds" ]; then
        ssh -n "$SERVER" "$stop_cmds"
    fi

    # 4. KILL LOGGER AGGRESSIVELY (This is the critical fix)
    # We kill by process name and tag to ensure no overlap
    ssh -n "$SERVER" "pkill -f 'raplog.sh.*-t $name'"
    sleep 2
}

# --------------------------------------------------
# Define all tests (semicolon-separated: name;url;ssh_cmds)
# --------------------------------------------------
# tests="
# "



tests="
baseline;http://${SERVER_HOST}/adrn-3/framework/baseline/hello_pg;rc-service nginx restart && rc-service fcgiwrap restart;rc-service nginx stop && rc-service fcgiwrap stop
f3;http://${SERVER_HOST}/adrn-3/framework/f3/;rc-service php-fpm85 restart && rc-service nginx restart;rc-service nginx stop && rc-service php-fpm85 stop
laravel;http://${SERVER_HOST}/adrn-3/framework/laravel/public/;rc-service php-fpm85 restart && rc-service nginx restart;rc-service nginx stop && rc-service php-fpm85 stop
sinatra;http://${SERVER_HOST}/;cd /var/www/localhost/htdocs/adrn-3/framework/sinatra/ && nohup bundle exec puma -b tcp://0.0.0.0:80 > /dev/null 2>&1 &;pkill -f puma
rail;http://${SERVER_HOST}/;cd /var/www/localhost/htdocs/adrn-3/framework/rail/ && nohup bundle exec puma -e production -b tcp://0.0.0.0:80 > /dev/null 2>&1 &;pkill -f puma
flask;http://${SERVER_HOST}/adrn-3/flask/;cd /var/www/localhost/htdocs/adrn-3/framework/flask/ && rc-service nginx restart && nohup venv/bin/gunicorn -w 4 -b unix:/run/flask.sock index:app > /dev/null 2>&1 &;pkill -f gunicorn
django;http://${SERVER_HOST}/adrn-3/django/hello;cd /var/www/localhost/htdocs/adrn-3/framework/django/ && rc-service nginx restart && nohup venv/bin/gunicorn -w 4 -b unix:/run/django.sock mysite.wsgi:application > /dev/null 2>&1 &;pkill -f gunicorn
fastify;http://${SERVER_HOST}/adrn-3/fastify/;cd /var/www/localhost/htdocs/adrn-3/framework/fastify/ && rc-service nginx restart && pm2 -f start server.js --name fastify-app;pm2 delete fastify-app
express-app;http://${SERVER_HOST}/adrn-3/express/;cd /var/www/localhost/htdocs/adrn-3/framework/express/ && rc-service nginx restart && pm2 -f start app.js --name express-app;pm2 delete express-app
"

# --------------------------------------------------
# Run all tests
# --------------------------------------------------
echo "$tests" | while IFS= read line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    # Split line into 4 fields: name; url; start_cmds; stop_cmds
    name=$(echo "$line" | cut -d';' -f1 | sed 's/^ *//;s/ *$//')
    url=$(echo "$line" | cut -d';' -f2 | sed 's/^ *//;s/ *$//')
    start_cmds=$(echo "$line" | cut -d';' -f3 | sed 's/^ *//;s/ *$//')
    stop_cmds=$(echo "$line" | cut -d';' -f4- | sed 's/^ *//;s/ *$//')  # take rest of line for stop_cmds
    echo ""
    echo "--- Run test $name -> $url ---"
    run_test "$name" "$url" "$start_cmds" "$stop_cmds"
    echo ""
done

# --------------------------------------------------
# Download Log
# --------------------------------------------------
echo ""
echo "======================================"
echo "Downloading Power Log..."
scp "$SERVER:$MASTER_REMOTE_PATH" "$OUTPUT_FOLDER/${TEST_NAME}_rapl.csv"

echo ""
echo "Research Data Collected:"
echo "1. Power Data:  $OUTPUT_FOLDER/${TEST_NAME}_rapl.csv"
echo "2. Event Data:  $EVENT_LOG"
