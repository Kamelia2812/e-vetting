FROM tomcat:9-jre17
ENV JAVA_OPTS="-Djava.rmi.server.hostname=127.0.0.1 -Djava.net.preferIPv4Stack=true"
RUN rm -rf /usr/local/tomcat/webapps/*
COPY dist/assessmentvetting.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
