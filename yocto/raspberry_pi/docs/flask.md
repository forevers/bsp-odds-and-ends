# Flask Web Application Framework

- verify flask server
    - place rpi on network with eth0 or wlan
        - verify service is running and logging
        ```console
        root@ess-hostname:~# systemctl status ess-flask-app
        * ess-flask-app.service - Flash ESS application
            Loaded: loaded (8;;file://ess-hostname/lib/systemd/system/ess-flask-app.service/lib/systemd/system/ess-flask-app)
            Active: active (running) since Thu 2022-04-28 11:07:00 PDT; 2min 45s ago
        Main PID: 259 (python3)
            Tasks: 4 (limit: 1828)
            CGroup: /system.slice/ess-flask-appservice
                    `- 259 python3 /usr/bin/ess-flask-app.py

        root@ess-hostname:~# journalctl -u  ess-flask-app | grep Flask
        Apr 28 11:07:02 ess-hostname ess-flask-app.py[259]:  * Serving Flask app 'ess-flask-app' (lazy loading)
        ...
        ```
        - in a browser enter the following address 192.168.1.25:5000 and verify script returning expected info
            ```console
            Linux ess-hostname 5.15.34-v8 #1 SMP PREEMPT Tue Apr 19 19:21:26 UTC 2022 aarch64 GNU/Linux
            ```

### flask references
https://flask.palletsprojects.com/en/2.2.x/quickstart/#a-minimal-application
https://hackersandslackers.com/flask-routes/
