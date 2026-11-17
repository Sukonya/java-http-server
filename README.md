# Java HTTP Server
Simple Java HTTP server (port 8000) running on Ubuntu Server 26.04.1

## Run manually
- javac SimpleHttpServer.java
- java SimpleHttpServer
## Run using a script
Added a script to launch/stop the server. Ensures that only a single command can handle starting and stopping the server.
- ./server.sh start
- curl http://localhost:8000
- ./server.sh stop
## A set of scripts for the JAR
javac compiles .java file into .class files, and jar bundles them into server.jar. By doing this, we can bundle multiple Java program files and resources into a single file. 
- To build a jar file-> javac SimpleHttpServer.java
        jar cfe "$JAR_FILE" SimpleHttpServer *.class
- To run it-> java -jar server.jar.
To test the jar scripts-> ./server-jar.sh build
curl http://localhost:8000
ls (server.jar should now exist)
./server-jar.sh restart
./server-jar.sh stop 
## Run as a systemd service
To ensure that we do not need to manually run the server everytime we start our pc, we can create systemd files that ensure that the http server automatically starts at each reboot
- sudo systemctl daemon-reload
- sudo systemctl enable --now java-server
## Systemd commands
- sudo systemctl stop java-server
- sudo systemctl start java-server
- sudo systemctl restart java-server
- sudo systemctl disable java-server (no longer starts at boot)
- journalctl -u java-server -f (live logs, Ctrl+C to exit)
- After editing the .service file, always run-> sudo systemctl daemon-reload.
After recompiling the Java file, run-> sudo systemctl restart java-server.
## Check status
- sudo systemctl status java-server
- curl http://localhost:8000
- to see in windows-> In VirtualBox, add a second port forwarding rule: TCP, Host Port 8000, Guest Port 8000, Host IP 127.0.0.1. Then open http://127.0.0.1:8000 in Windows browser.
## Manual Docker image
- docker pull eclipse-temurin:25-jdk
- docker run -dit --name builder eclipse-temurin:25-jdk bash
- docker exec builder mkdir -p /app
- docker cp ~/httpserver/SimpleHttpServer.java builder:/app/
- docker exec -it builder bash
-  cd /app
-  ls -l
-  javac SimpleHttpServer.java
-  jar cfe server.jar SimpleHttpServer *.class
-  java -jar server.jar
-  exit

Problem with this: once the pc is shut down or the server is down, all the steps are lost and have to be rewritten from scratch. To avoid this, we can instead use Dockerfile to create our docker image.
## Docker image with Dockerfile

