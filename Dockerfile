FROM eclipse-temurin:25-jdk

WORKDIR /app

COPY SimpleHttpServer.java .

RUN javac SimpleHttpServer.java && jar cfe server.jar SimpleHttpServer *.class

EXPOSE 8000

CMD ["java", "-jar", "server.jar"]
