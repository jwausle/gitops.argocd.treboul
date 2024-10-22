FROM eclipse-temurin:17-jre-alpine

RUN mkdir app
COPY target/treboul.spring.sample.jar app/treboul.spring.sample.jar
EXPOSE 8080

ENTRYPOINT [ \
  "java", \
  # print verbose jvm infos on startup \
  "-XX:+PrintFlagsFinal", \
  # show inital memory allocation on startup \
  "-XshowSettings:vm", \
  "-jar", \
  "app/treboul.spring.sample.jar" \
]