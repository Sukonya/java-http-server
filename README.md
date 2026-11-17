# Java HTTP Server
Simple Java HTTP server (port 8000) running on Ubuntu Server 26.04.1

## Run manually
- javac SimpleHttpServer.java
- java SimpleHttpServer

## Run as a systemd service
- sudo systemctl daemon-reload
- sudo systemctl enable --now java-server

## Systemd commands
- sudo systemctl stop java-server
- sudo systemctl start java-server
- sudo systemctl restart java-server
- sudo systemctl disable java-server (no longer starts at boot)
- journalctl -u java-server -f (live logs, Ctrl+C to exit)
After editing the .service file, always run-> sudo systemctl daemon-reload.
After recompiling the Java file, run-> sudo systemctl restart java-server.

## Check status
- sudo systemctl status java-server
- curl http://localhost:8000
- to see in windows-> In VirtualBox, add a second port forwarding rule: TCP, Host Port 8000, Guest Port 8000, Host IP 127.0.0.1. Then open http://127.0.0.1:8000 in Windows browser.
