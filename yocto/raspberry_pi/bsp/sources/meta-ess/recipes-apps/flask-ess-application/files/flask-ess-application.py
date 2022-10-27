#!/usr/bin/env python3

# https://flask.palletsprojects.com/en/2.2.x/quickstart/#a-minimal-application

import os
from flask import Flask

app = Flask(__name__)

cmd = "uname -a"

@app.route("/")
def hello_world():
    uname = os.popen(cmd).read()
    return "<p>" + uname + "</p>"

if __name__ == '__main__':
    app.run(host='0.0.0.0')