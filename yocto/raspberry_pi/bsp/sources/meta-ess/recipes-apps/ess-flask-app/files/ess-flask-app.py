#!/usr/bin/env python3

# https://flask.palletsprojects.com/en/2.2.x/quickstart/#a-minimal-application

import os
from flask import Flask
# escape to flatten scripts to strings (security)
from markupsafe import escape

app = Flask(__name__)

cmd = "uname -a"

@app.route('/projects/')
def projects():
    return 'The project page'

@app.route('/usage')
@app.route('/about')
def about():
    usage = f'/: uname -a <br/>cpuinfo: cat /proc/cpuinfo <br/>cat/<path:cat_path>: cat a path'
    return usage

@app.route("/")
def uname_a():
    cmd = "uname -a"
    uname = os.popen(cmd).read()
    return f"<p>/: {escape(uname)}</p>"

@app.route("/cpuinfo")
def cat_cpuinfo():
    cpu_info = os.popen("cat /proc/cpuinfo").read()
    cpu_info = cpu_info.replace('\n', '<br/>')
    return f"<p>/cpuinfo: {cpu_info}</p>"

@app.route('/cat/<path:cat_path>')
def cat_file(cat_path):
    cmd = f'cat /{escape(cat_path)}'
    cat_string = os.popen(cmd).read()
    return f"{cmd}: {cat_string}"

if __name__ == '__main__':
    # make server publicly available
    app.run(host='0.0.0.0')