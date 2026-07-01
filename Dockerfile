FROM tomcat:8.5-jdk11-openjdk-slim
# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*
# Copy the built WAR file as the ROOT application so it's accessible directly at the domain root
COPY dist/assessmentvetting.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
