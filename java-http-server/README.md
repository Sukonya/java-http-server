# Java HTTP Server
Simple Java HTTP server (port 8000) running on Ubuntu Server 26.04.1
## Set up the VM
1. Create a new VM in VirtualBox from the Ubuntu Server ISO.
2. Install with OpenSSH server enabled.
3. Add the NAT port forwarding rules above.
4. Connect to terminal by `ssh vboxuser@127.0.0.1 -p 2222(port number used to connect pc to server.)`
## Repository layout
| Path | Contents |
|---|---|
| `java-http-server/` | The Maven project: `pom.xml`, `Dockerfile`, `src/` |
| `infra/systemd/` | systemd unit file (runs the server in the background) |
| `infra/jenkins/` | Copy of the Jenkins pipeline script |
| `infra/scripts/` | Start/stop scripts for the server and the JAR file, built before configuring Maven and Docker |
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
- To compile-> javac SimpleHttpServer.java
- To build a jar file-> jar cfe "$JAR_FILE" SimpleHttpServer *.class
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
## Build and run with Maven
javac only compiles Java source files into bytecode, whereas Maven automates the entire software build lifecycle. We can build, jar and test files much more efficiently. Thus, we moved from javac to maven in this step.


```bash
cd java-http-server
mvn -B clean package        # compile, test, build target/server.jar
java -jar target/server.jar
curl http://localhost:8000
```

`pom.xml` sets the Java version, the output name (`server.jar`), and the main class.
## Manual Docker image
We create and use Docker images to package an application together with everything it needs to run — code, runtime, libraries, and settings into a single, portable template
- docker pull eclipse-temurin:25-jdk\
docker run -dit --name builder eclipse-temurin:25-jdk bash\
docker exec builder mkdir -p /app\
docker cp ~/httpserver/SimpleHttpServer.java builder:/app/\
docker exec -it builder bash\
  cd /app\
  ls -l\
  javac SimpleHttpServer.java\
  jar cfe server.jar SimpleHttpServer *.class\
  java -jar server.jar\
  exit

Problem with this: once the pc is shut down or the server is down, all the steps are lost and have to be rewritten from scratch. To avoid this, we can instead use Dockerfile to create our docker image.
## Docker image with Dockerfile
The Dockerfile copies the JAR that Maven built. A Dockerfile is better than manually creating an image because the steps are written down, repeatable, and reviewable.

- cd java-http-server
- mvn -B clean package
- build the image-> docker build -t sukonya/java-server:latest .
- run the image-> docker run -d --name my-java-server -p 8000:8000 --restart unless-stopped sukonya/java-server:latest (-d = start the server in the background, -p = map port 8000.)
- check existing images-> docker images
- check running containers-> docker ps
- check all containers-> docker ps -a
- live logs -> docker logs -f my-java-server

to push the image to Docker Hub-> docker tag java-server YOURUSER/java-server:1.0\
docker tag java-server YOURUSER/java-server:latest\
docker push YOURUSER/java-server:1.0\
docker push YOURUSER/java-server:latest

to check if the server runs properly-> docker run -d --name any-unique-name -p 8000:8000 YOURUSER/java-server:1.0\
curl http://localhost:8000
## Docker Hub

```bash
docker login -u sukonya          # use an access token as the password
docker tag java-server sukonya/java-server:1.0
docker push sukonya/java-server:1.0
docker push sukonya/java-server:latest
```

Image: `sukonya/java-server`. Each Jenkins build pushes a tag with its build number, plus `latest` is set to whichever is the latest build number that we are currently using.
## Jenkins pipeline

Jenkins runs on the VM at `http://127.0.0.1:8080`. The Docker Hub login is stored as a Jenkins credential with the ID `dockerhub`. The pipeline script is in `infra/jenkins/Jenkinsfile`.

| Stage | What it does |
|---|---|
| 1. Clone | Downloads the code from GitHub |
| 2. Build | `mvn -B clean package` compiles, runs the test, builds `target/server.jar` |
| 3. Push artifacts | Archives `server.jar` in Jenkins, builds the image, pushes it to Docker Hub |
| 4. Deploy | Replaces the `my-java-server` container with the new image |
| 5. Test | Waits 5 seconds, then `curl -f http://localhost:8000` must succeed |

If any stage fails, the later stages are skipped, so a broken build is never
pushed or deployed.

## Troubleshooting

| Problem | Fix |
|---|---|
| `port is already allocated` | `docker ps -a`, then `docker rm -f NAME` | 
| to check if port is occupied-> sudo ss -tlnp | grep 8000
| `no main manifest attribute` | Check `mainClass` in `pom.xml` |
| Jenkins `permission denied...` | `sudo usermod -aG docker jenkins`, then restart Jenkins |
| Jenkins Stage 5 `Connection refused` or `reset` | The server needs more start-up time, so raise the `sleep` |
