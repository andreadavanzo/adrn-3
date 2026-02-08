#!/usr/bin/env python3

# Audax Development Research Notes - 3
# https://github.com/andreadavanzo/adrn-3
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Andrea Davanzo

from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def hello():
    greeting_text = 'hello world'
    return render_template('index.html', greeting=greeting_text)

if __name__ == "__main__":
    app.run(unix_socket="/run/flask.sock")

