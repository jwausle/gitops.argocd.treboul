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

* github-action: [build-service](https://github.com/treboulit/kubernetes-environment-concept/blob/main/.github/workflows/build-service.yaml)
* git-tag: `vX.Y.Z` (e.g. [v1.0.0](https://github.com/treboulit/kubernetes-environment-concept/tree/v1.0.0))