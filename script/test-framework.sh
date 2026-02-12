#!/bin/sh
#
# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

SERVER="$1"
OUTPUT_FOLDER="$2"
TEST_NAME="${3:-test}"
NUM_ITERATIONS="${4:-5}"      # Number of times to repeat the whole cycle
REQUEST_DELAY="${5:-0.250}"
MODE="${6:-time}"             # 'time' or 'count'
TIME_OR_COUNT="${7:-200}"    # Seconds for 'time' mode, Total requests for 'count' mode

START_SLEEP=10
RAPLOG_SLEEP=1

if [ -z "$SERVER" ] || [ -z "$OUTPUT_FOLDER" ]; then
    echo "Usage: $0 <server> <output_folder> [test_name] [iterations] [delay] [mode: time|count] [val]"
    exit 1
fi

SERVER_HOST=$(echo "$SERVER" | sed 's/.*@//')
mkdir -p "$OUTPUT_FOLDER"

MASTER_REMOTE_PATH="/tmp/raplog_${TEST_NAME}.csv"
EVENT_LOG="$OUTPUT_FOLDER/${TEST_NAME}_events.csv"

# Initialize Event Log
echo "timestamp,tag,request_num,status" > "$EVENT_LOG"

# --------------------------------------------------
# Pre-Test Setup
# --------------------------------------------------
echo "--- Initializing Hardware State on remote server ---"
ssh -n "$SERVER" "sh /root/performance.sh && sh /root/noturbo.sh && rm -f $MASTER_REMOTE_PATH"
ssh -n "$SERVER" "pkill -f raplog.sh; fuser -k 80/tcp"

# --------------------------------------------------
# Mode 1: Time-Based Block Test
# --------------------------------------------------
run_test() {
    name=$1; url=$2; round=$3
    echo "--- Starting Time Block Test: $name (Round $round, $TIME_OR_COUNT seconds) ---"

    req_count=0
    start_time=$(date +%s)
    end_time=$((start_time + TIME_OR_COUNT))

    while [ $(date +%s) -lt $end_time ]; do
        req_count=$((req_count + 1))
        ts=$(date +"%Y-%m-%d %H:%M:%S.%N")
        status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 "$url")
        echo "$ts,$name,${round}_${req_count},$status" >> "$EVENT_LOG"
        printf "\r--- %s | Round: %d | Req: %d | Time Left: %ds   " "$name" "$round" "$req_count" "$((end_time - $(date +%s)))"
        sleep "$REQUEST_DELAY"
    done
}

# --------------------------------------------------
# Mode 2: Count-Based Test
# --------------------------------------------------
run_count() {
    name=$1; url=$2; round=$3
    echo "--- Starting Count-Based Test: $name (Round $round, $TIME_OR_COUNT requests) ---"

    for req_idx in $(seq 1 "$TIME_OR_COUNT"); do
        ts=$(date +"%Y-%m-%d %H:%M:%S.%N")
        status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url")

        echo "$ts,$name,${round}_${req_idx},$status" >> "$EVENT_LOG"
        printf "\r--- %s | Round: %d | Req: %d/%d | Stat: %s   " "$name" "$round" "$req_idx" "$TIME_OR_COUNT" "$status"
        sleep "$REQUEST_DELAY"
    done
}

# --------------------------------------------------
# Test Definitions
# --------------------------------------------------
tests="
f3;http://${SERVER_HOST}/adrn-3/framework/f3/;rc-service php-fpm85 restart && rc-service nginx restart;rc-service nginx stop && rc-service php-fpm85 stop
laravel;http://${SERVER_HOST}/adrn-3/framework/laravel/public/;cd /var/www/localhost/htdocs/adrn-3/framework/laravel/ && rc-service php-fpm85 restart && rc-service nginx restart;rc-service nginx stop && rc-service php-fpm85 stop
sinatra;http://${SERVER_HOST}/;cd /var/www/localhost/htdocs/adrn-3/framework/sinatra/ && nohup bundle exec puma -e production -b tcp://0.0.0.0:80 > /dev/null 2>&1 &;pkill -f puma
rail;http://${SERVER_HOST}/;cd /var/www/localhost/htdocs/adrn-3/framework/rail/ && nohup env bundle exec puma -e production -b tcp://0.0.0.0:80 > /dev/null 2>&1 &;pkill -f puma
flask;http://${SERVER_HOST}/adrn-3/flask/;cd /var/www/localhost/htdocs/adrn-3/framework/flask/ && rc-service nginx restart && nohup venv/bin/gunicorn -b unix:/run/flask.sock index:app > /dev/null 2>&1 &;pkill -f gunicorn && rc-service nginx stop
django;http://${SERVER_HOST}/adrn-3/django/;cd /var/www/localhost/htdocs/adrn-3/framework/django/ && rc-service nginx restart && nohup venv/bin/gunicorn -b unix:/run/django.sock mysite.wsgi:application > /dev/null 2>&1 &;pkill -f gunicorn && rc-service nginx stop
fastify;http://${SERVER_HOST}/adrn-3/fastify/;cd /var/www/localhost/htdocs/adrn-3/framework/fastify/ && rc-service nginx restart && NODE_ENV=production pm2 -f start server.js --name fastify-app;pm2 delete fastify-app && rc-service nginx stop
express-app;http://${SERVER_HOST}/adrn-3/express/;cd /var/www/localhost/htdocs/adrn-3/framework/express/ && rc-service nginx restart && NODE_ENV=production pm2 -f start app.js --name express-app;pm2 delete express-app && rc-service nginx stop
"

# --------------------------------------------------
# Execution Switch
# --------------------------------------------------
echo "$tests" | while IFS=';' read -r name url start stop; do
    [ -z "$name" ] && continue

    round=1
    while [ "$round" -le "$NUM_ITERATIONS" ]; do
        # 1. START SERVICE
        [ -n "$start" ] && ssh -n "$SERVER" "$start"
        sleep "$START_SLEEP"

        # 2. START LOGGER
        ssh -n "$SERVER" "nohup sh /root/raplog.sh -o $MASTER_REMOTE_PATH -i 1 -t $name >/dev/null 2>&1 &"
        sleep "$RAPLOG_SLEEP"

        # 3. RUN THE SELECTED TEST MODE
        if [ "$MODE" = "count" ]; then
            run_count "$name" "$url" "$round"
        else
            run_test "$name" "$url" "$round"
        fi

        echo ""
        # 4. STOP LOGGER
        ssh -n "$SERVER" "pkill -f 'raplog.sh.*-t $name'"

        # 5. STOP SERVICE
        [ -n "$stop" ] && ssh -n "$SERVER" "$stop"

        # 6. COOLDOWN
        printf "Round %d/%d for %s complete. Cooldown sleep..." "$round" "$NUM_ITERATIONS" "$name"
        sleep 30
        echo "Done."
        round=$((round + 1))
    done
    echo "--- Completed all rounds for $name ---"
done

# --------------------------------------------------
# Download Log
# --------------------------------------------------
echo "--- Downloading Power Log ---"
scp "$SERVER:$MASTER_REMOTE_PATH" "$OUTPUT_FOLDER/${TEST_NAME}_rapl.csv"
echo "Results stored in $OUTPUT_FOLDER"