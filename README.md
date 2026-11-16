# Java HTTP Server
Simple Java HTTP server (port 8000) running on Ubuntu Server 26.04.1

## Run manually
javac SimpleHttpServer.java
java SimpleHttpServer

## Run as a systemd service
sudo systemctl daemon-reload
sudo systemctl enable --now java-server

## Check status
sudo systemctl status java-server
curl http://localhost:8000
