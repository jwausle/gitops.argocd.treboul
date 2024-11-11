# Helm charts

* [spring-boot-app](./spring-boot-app)
* [whoami](./whoami)

## Deploying the helm charts

```mermaid
flowchart LR
    subgraph "Continuous Integration (CI)"
        subgraph Docker-Registry
            Image
        end
    end
    Image --> Chart
    Chart --> Deploy
    subgraph "Continuous Deployment (CD) "
        direction LR
        Deploy --> Helmchart
        subgraph Github 
            Deploy
        end
        subgraph Helm-Repository
            Helmchart
        end
    end
```

1. After the new Image build and pushed to the Docker Registry
2. Update the helmchart if necessary 
3. Deploy the helmchart to Helm Repository

ArgoCD continuously pull the changes of the helmcharts 
to sync the applications into the cluster when chart 
version ranges are configured. 

## Helm chart: spring-boot

The spring-boot helm chart is a general chart that deploys a spring boot service. The chart is a simple example of how to deploy a spring boot service using helm.

## Helm chart: whoami

The whoami helm chart is a simple helm chart that deploys a whoami service. The chart is a simple example of how to deploy a whoami service using helm.