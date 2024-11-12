# CI/CD concept 

The (C)ontinous (I)integration/(C)ountinous (D)eployment concept 
to host and maintain domain ligidi.africa ([link](https://ligidi.africa)).

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
            argocd.ligidi.africa
        }    
    }
    
```

## Domain 'ligidi.africa'

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

## Contributing

1. Enhance `ligidi.africa` cluster setup ([link](./infrastructure))
2. Enhance `argocd.ligidi.africa` argocd applications ([link](./infrastructure/argocd))    
3. Enhance `helm.ligidi.africa` helmcharts ([link](./helmcharts))
4. Enhance sample service ([link](./service))

The 3 subdirectories [./infrastructure](./infrastructure), [./helmcharts](./helmcharts) and [./service](./service) 
should be 3 separate repositories. For the concept it's sufficient
that the directories represent this repository.

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

> **All ArgoCD applications are helmcharts**

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
    CI ->> HelmRepository: (3,4) helm push
    activate HelmRepository
    note right of HelmRepository: Chart:v2.0.0
    Developer ->> CD: (5) git push main - Integrate Image:v1.1.0, Chart:v2.0.0 into Argocd Application
    Note right of CD: Configure<br/>next Deployment <br/>in GitRepo
    Developer ->> CD: (6) git push prod - Move deployment tag to next deployment commit
    Note right of CD: Move Git Tag `prod`<br/>identify deployment <br/> commit
    loop ArgoCD sync
    Argocd ->>CD: (7) fetch
    activate Argocd
    Argocd ->>Kubernetes: (7) deploy
    deactivate Argocd
    end
    deactivate DockerRegistry
    deactivate HelmRepository
```