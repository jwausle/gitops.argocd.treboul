# Sample spring boot service

The Sample spring boot service.

Requirements:
* java   >=17
* mvn    >=3.8.3
* docker >=20.10.8

## Getting Started

```
mvn clean package
java -jar target/spring.sample.jar
```

> curl http://localhost:8080/atctuator/health

```
docker build -t docker.ligidi.africa/spring.sample:latest .
```