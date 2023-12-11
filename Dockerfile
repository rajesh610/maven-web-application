
FROM adoptopenjdk/openjdk11:alpine-jre
WORKDIR /opt/app
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","app.jar"]
