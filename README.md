# CI/CD concept 

The (C)ontinous (I)integration/(C)ountinous (D)eployment concept 
to host and maintain domain ligidi.africa ([link](https://ligidi.africa)).

## CI/CD process

```mermaid
flowchart LR
    Develop --> Build
    subgraph "Continuous Integration (CI)"
        subgraph Github 
            Build 
        end
        subgraph Docker-Registry
            Image
        end
        Build --> Image
    end
    Image --> Chart
    Chart --> Deploy
    subgraph "Continuous Deployment (CD)" 
        direction LR
        Deploy --> Helmchart
        subgraph Github 
            Deploy
        end
        subgraph Helm-Repository
            Helmchart
        end
        subgraph "Kubernetes Cluster"
            Argocd --> Helmchart
            Argocd --> Helmchart-Release
        end
    end
```

### The service development+deployment livecycle is:

1. Developer implement the feature in the service repository (example - [./service](./service))
2. The CI (Github-Action) build and deploy the service as image to the docker registry ([https://docker.ligidi.africa](https://docker.ligidi.africa)) on any `main` branch push
3. (Optional) Update the helmchart if necessary ([./helmcharts](./helmcharts))
4. (Optional) Deploy the helmchart to the helm repository ([https://helm.ligidi.africa](https://helm.ligidi.africa))
5. Integrate the new Image in the argocd application ([infrastructure/argocd/app]) to deploy the service in the cluster
6. The CD (Github-Action) tag the argocd application
7. ArgoCD sync the application changes into the cluster

### Deployment sequence

The general development branch is `main` and the production deployment tag is `prod`.
The CI/CD process follows the GitFlow pattern([link](https://docs.github.com/en/get-started/using-github/github-flow)).

> **All ArgoCD applications schedule helmcharts deployments**

```mermaid
sequenceDiagram
    participant Developer
    box LightYellow Countinous Integration (CI
    participant CI
    participant DockerRegistry
    participant HelmRepository
    end
    box LightCyan Countinous Deployment (CD)
    participant CD
    participant Argocd
    participant Kubernetes
    end
    Developer ->> CI: (1) git push main
    CI ->>DockerRegistry: (2) docker push
    activate DockerRegistry
    note right of DockerRegistry: Image:v1.0.0
    CI ->> CD: (3) git push main - Integrate Image:v1.1.0, Chart:v2.0.0 into Argocd Application
    activate CD
    Note right of CD: CI<br/>auto deploy <br/>in GitRepo
    CI ->> HelmRepository: (4,5) helm push
    activate HelmRepository
    note right of HelmRepository: Chart:v2.0.0
    Developer ->> CD: (6) git push prod - Move deployment tag to next deployment commit
    activate CD
    Note right of CD: Move Git Tag `prod`<br/>identify deployment <br/> commit
    loop ArgoCD sync
    Argocd ->>CD: (7) fetch
    activate Argocd
    Argocd ->>Kubernetes: (7) deploy
    deactivate Argocd
    end
    deactivate DockerRegistry
    deactivate HelmRepository
    deactivate CD
    deactivate CD
```

## Domain 'ligidi.africa'

```mermaid
stateDiagram
    direction LR
    [*] --> argocd.ligidi.africa
    [*] --> docker.ligidi.africa
    [*] --> helm.ligidi.africa
    [*] --> Traefik(ligidi.africa/*)
    state Host(ligidi.africa) {
        direction LR
        state Docker {
            helm.ligidi.africa
            docker.ligidi.africa
        }
        state Kubernetes {
            direction LR
            Traefik(ligidi.africa/*) --> Service(whoami)
            Traefik(ligidi.africa/*) --> Service(spring)
            Traefik(ligidi.africa/*) --> Service(quarkus)
            argocd.ligidi.africa
        }    
    }
    
```

* link: https://ligidi.africa
* link: https://ligidi.africa/api/spring-sample/index.html - sample web side
* link: https://ligidi.africa/api/spring-sample/any/other/path
* link: https://ligidi.africa/api/quarkus-sample/index.html - sample web side
* link: https://ligidi.africa/api/quarkus-sample/all - loaded properties
* link: https://ligidi.africa/api/quarkus-sample/any/other/path 
* link: https://ligidi.africa/api/whoami/any/other/path

### Reverse proxy dashboard - https://ligidi.africa/dasboard/#

* user: admin
* password: **** (hint: equal username)

The Traefik dashboard is the place that shows the current
active routes, services and middlewares handled by Traefik.

### Sample service whoami - https://ligidi.africa/whoami/test

Sample service installation maintained by argocd.

```
curl -L https://ligidi.africa/whoami/test
```

## Sub-domain 'argocd.ligidi.africa'

(C)ontinous (D)eployment installation Argo-CD([link](https://argo-cd.readthedocs.io/en/stable/))
to maintain the `ligidi.africa` services as applications.

* link: https://argocd.ligidi.africa
* user: admin
* password: **** (hint: equal username)

![argocd-ui.webp](./.img/argocd-ui.webp)

## Sub-domain 'docker.ligidi.africa'

Self-hosted docker registry to share service images to run them in the cluster.

* user: admin
* password: **** (hint: equal username)

```
docker login docker.ligidi.africa
docker pull docker.ligidi.africa/whoami:latest
docker push ...
```

## Sub-domain 'helm.ligidi.africa'

> GET https://helm.ligidi.africa/charts # has no access permission

Write/push user:
* user: admin
* password: **** (hint: equal username)

> Not supported: `helm repo add`

## Monitoring 'ligidi.africa'

* link: https://ligidi.africa/grafana
* user: admin
* password: **** (hint: equal username)

![usecase-grafana-loki.mp4](.img/usecase-grafana-loki.webp)

## Contributing

1. Enhance `ligidi.africa` cluster setup ([link](./infrastructure))
2. Enhance `argocd.ligidi.africa` argocd applications ([link](./infrastructure/argocd))
3. Enhance `helm.ligidi.africa` helmcharts ([link](./helmcharts))
4. Enhance sample service ([link](./service))

The 3 subdirectories [./infrastructure](./infrastructure), [./helmcharts](./helmcharts) and [./service](./service)
should be 3 separate repositories. For the concept it's sufficient
that the directories represent this repository.

## Github-Actions

1. build and push helmchart [spring-boot-app](.github/workflows/build-helmchart-spring-boot-app.yaml)
2. build and push helmchart [whoami](.github/workflows/build-helmchart-whoami.yaml)
3. build and push image [sample-service](.github/workflows/build-service.yaml)
4. deploy next app release [argocd](.github/workflows/deploy.yaml)

### 1) Build and push spring-boot-app helmchart

Build and push new helmchart version to the helm repository 
on any change in the [./helmcharts/spring-boot-app](./helmcharts/spring-boot-app) directory.

* repository: https://helm.ligidi.africa
* chart: spring-boot-app

### 2) Build and push whoami helmchart

* repository: https://helm.ligidi.africa
* chart: whoami

### 3) Build and push image

* repository: https://docker.ligidi.africa
* image: sample-service

### 4) Deploy next app release

Move the `prod` tag ([link](https://github.com/treboulit/kubernetes-environment-concept/blob/prod)) 
to the current commit in the `main` branch ([link](https://github.com/treboulit/kubernetes-environment-concept/blob/main)).