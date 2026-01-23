#!/usr/bin/env python3

# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

from flask import Flask, Response
import psycopg2

app = Flask(__name__)

# PostgreSQL connection settings
dbhost = '192.168.37.131'
dbname = 'postgres'
dbuser = 'tester'
dbpass = 'tester'

@app.route("/")
def hello():
    # Connect to the database
    conn = psycopg2.connect(
        host=dbhost,
        dbname=dbname,
        user=dbuser,
        password=dbpass
    )
    cur = conn.cursor()

    # Execute query
    cur.execute("SELECT 'hello world' AS greeting;")
    row = cur.fetchone()

    cur.close()
    conn.close()

    # Return the result as plain text
    return Response(row[0] if row else 'error', mimetype="text/plain")

if __name__ == "__main__":
    app.run(unix_socket="/run/flask.sock")

