FROM tomcat:8.0.20-jre8

COPY java-web-app.war /usr/local/tomcat/webapps/gradle-web-app.war
