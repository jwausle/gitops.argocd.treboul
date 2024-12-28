FROM eclipse-temurin:17-jre-alpine

RUN mkdir /app
WORKDIR /app

COPY target/quarkus-app/ /app/quarkus-app
EXPOSE 8080

ENTRYPOINT [ \
  "java", \
  # print verbose jvm infos on startup \
  "-XX:+PrintFlagsFinal", \
  # show inital memory allocation on startup \
  "-XshowSettings:vm", \
  "-jar", \
  "/app/quarkus-app/quarkus-run.jar" \
]