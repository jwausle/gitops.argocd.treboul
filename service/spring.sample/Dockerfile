FROM eclipse-temurin:17-jre-alpine

RUN mkdir app
COPY target/spring.sample.jar app/spring.sample.jar
EXPOSE 8080

ENTRYPOINT [ \
  "java", \
  # print verbose jvm infos on startup \
  "-XX:+PrintFlagsFinal", \
  # show inital memory allocation on startup \
  "-XshowSettings:vm", \
  "-jar", \
  "app/spring.sample.jar" \
]