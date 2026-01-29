#!/usr/bin/env python3

# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

from flask import Flask, render_template
import psycopg2

app = Flask(__name__)

# PostgreSQL connection settings
dbhost = '192.168.37.131'
dbname = 'postgres'
dbuser = 'tester'
dbpass = 'tester'

@app.route("/")
def hello():
    conn = psycopg2.connect(
        host=dbhost,
        dbname=dbname,
        user=dbuser,
        password=dbpass
    )
    cur = conn.cursor()
    cur.execute("SELECT 'hello world' AS greeting;")
    row = cur.fetchone()
    cur.close()
    conn.close()

    # Pass the database result to the HTML template
    greeting_text = row[0] if row else 'error'
    return render_template('index.html', greeting=greeting_text)

if __name__ == "__main__":
    app.run(unix_socket="/run/flask.sock")

