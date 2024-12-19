# Common helm chart for spring boot apps

## Quickstart

```shell
cd spring-boot-app
```

### Install a microservice with the chart

To install a microservice, you will have to override the `image.repository`, `image.tag` values:

> **NOTE:** In a real deployment you might have to specify `ingressroute.path` as well. When testing
> locally, and you do not want to deploy an ingress route, specify `ingressroute.enabled=false` to
> disable deployment of an ingress route.

```shell
helm upgrade --install <RELEASE> . --set image.repository=<IMAGE>,image.tag=<VERSION>,ingressroute.path=<PATH>
```

## Chart Properties

| Name                                   | Description                                                                                                                                                                                                                                                                                                                                                                                                                                    | Default Value                                 |
|----------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------|
| `image.repository`                     | (**Mandatory**) Specifies the spring boot applications image to be installed                                                                                                                                                                                                                                                                                                                                                                   | `""`                                          |
| `image.tag`                            | (**Mandatory**) Specifies the spring boot applications image tag/version to be installed                                                                                                                                                                                                                                                                                                                                                       | `""`                                          |
| `app.pathInContainer`                  | The root path under which the spring boot jar is placed in the container. Is used to mount the configuration into the correct directory                                                                                                                                                                                                                                                                                                        | `"/etc/spring"`                               |
| `app.port`                             | Specify the port of the application. This will overwrite the server.port property which might have been bundled in an application properties file in tha spring boot application. However, it will not take any effect if a `SERVER_PORT` extra-env or `server.port` property underneath `app.config` or `app.rawConfig` is defined                                                                                                            | `8080`                                        |
| `app.liveness`                         | Path to the http liveness endpoint of the application (typically the actuator health endpoint). The default automatically detects if `server.servlet.context-path` is configured (but only, if it is configured through the helm chart) and prepends the context path accordingly.                                                                                                                                                             | `/internal/actuator/health/liveness`          |
| `app.readiness`                        | Path to the http readiness endpoint of the application (typically the actuator health endpoint). The default automatically detects if `server.servlet.context-path` is configured (but only, if it is configured through the helm chart) and prepends the context path accordingly.                                                                                                                                                            | `/internal/actuator/health/readiness`         |
| `app.config`                           | An object containing arbitrary spring boot properties. All properties specified here will be passed as application properties to the spring boot application inside the container. See [Configuration](#Configuration) for details.                                                                                                                                                                                                            | `{}`                                          |
| `app.rawConfig`                        | Similar to `app.config`, but properties are defined rawly (as a string). This has the benefit that helm variables can be used. See [Configuration](#Configuration) for details.                                                                                                                                                                                                                                                                | `""`                                          |
| `app.secrets`                          | An array of secret objects that will be mounted into the container and made available as sprinig boot application properties. See [Secrets](#Secrets) for details.                                                                                                                                                                                                                                                                             | `[]`                                          |
| `app.defaultSecrets.actuators.enabled` | Enable usage of the default secret e.g. `spring-database`.                                                                                                                                                                                                                                                                                                                                                                                     | `false`                                       |
| `app.labels`                           | An object defining additional labels that should be applied to the application/deployment. The labels will not be applied to anything else. Typically used to make the service discoverable by other kubernetes operators (e.g., for allowing automatic proxy injection with linkerd). Helm variable substitution is supported. E.g.: <pre lang="yaml">app:<br>&nbsp;&nbsp;labels:<br>&nbsp;&nbsp;&nbsp;&nbsp;linkerd.io/inject: enabled</pre> | `{}`                                          |
| `extraEnv`                             | Extra kubernetes environment configuration that will be passed to the container. Must be specified as a string. Supports helm variable substitution. E.g.: <pre lang="yaml">extraEnv: &#x7C; <br>&nbsp;&nbsp;- name: SERVER_PORT<br>&nbsp;&nbsp;&nbsp;&nbsp;value: &quot;8081&quot;</pre>                                                                                                                                                      | `""`                                          |
| `extraVolumes`                         | Extra volume configurations. Must be specified as a string. Supports helm variable substitution. Usually used in conjunction with `extraVolumeMounts`. E.g.: <pre lang="yaml">extraVolumes: &#x7C;<br>&nbsp;&nbsp;- name: my-volume<br>&nbsp;&nbsp;&nbsp;&nbsp;configMap:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: additional-property-files</pre>                                                                                         | `""`                                          |
| `extraVolumeMounts`                    | Extra volume mount configurations. Must be specified as a string. Supports helm variable substitution. Usually used in conjunction with `extraVolumes`. E.g.: <pre lang="yaml">extraVolumeMounts: &#x7C;<br>&nbsp;&nbsp;- name: my-volume<br>&nbsp;&nbsp;&nbsp;&nbsp;mountPath: /opt/app/config</pre>                                                                                                                                          | `""`                                          |
| `service.labels`                       | An object defining additional labels that should be applied to the service.                                                                                                                                                                                                                                                                                                                                                                    | `monitor: "{{ .Release.Namespace }}-service"` |
| `ingressroute.enabled`                 | Enables or disables the deployment of traefik `IngressRoute` and `Middleware` resources for the service. See [Traefik](#Traefik) for details.                                                                                                                                                                                                                                                                                                  | `true`                                        |
| `ingressroute.cors.allowed`            | Enables or disables general CORS requests for the ingress route                                                                                                                                                                                                                                                                                                                                                                                | `false`                                       |
| `ingressroute.path`                    | The path under which the service should be made available. Must be specified, if `ingressroute.enabled` is set to true. See [Traefik](#Traefik) for details.                                                                                                                                                                                                                                                                                   | `"{{ .Release.Name }}"`                       |
| `debug`                                | Enables or disables printing of pod initialization details e.g. application.yaml and secret mount points                                                                                                                                                                                                                                                                                                                                       | `false`                                       |

See the default [values.yaml](./values.yaml) file for all possible configuration options

## Configuration

The chart allows to configure any spring boot application freely using the `app.config` and/or `app.rawConfig`
properties.
An `application.yaml` file will be generated using those values and mounted
underneath `{{ .Values.app.pathInContainer }}/config`
(spring boot looks for `application.yaml` files inside the config directory by default)

### `app.config`

Here you can specify arbitrary spring boot application properties directly in yaml format.

Example `values.yaml` with spring boot configuration:

```yaml
# values.yaml
app:
  config:
    server:
      port: 8081
    spring:
      datasource:
        username: postgres
```

The above configuration would result in the following `application.yaml` file to be mounted as configuration
for the spring boot app underneath the configured `app.pathInContainer`:

```yaml
# /opt/app/config/application.yaml (mounted in container)
server:
  port: 8081
spring:
  datasource:
    username: postgres
```

### `app.rawConfig`

Additionally, to `app.config`, you can specify spring boot properties through `app.rawConfig`. The difference
is that `app.rawConfig` takes a raw string (which must be valid yaml) and supports helm variable substitution.

Example `values.yaml` with spring boot `app.rawConfig` configuration:

```yaml
# values.yaml
app:
  rawConfig: |
    server:
      port: 8081
    spring:
      datasource:
        username: "{{ .Values.postgres.auth.username }}"
```

The above configuration would result in the following `application.yaml` file to be mounted as configuration
for the spring boot app underneath the configured `app.pathInContainer`:

```yaml
# /opt/app/config/application.yaml (mounted in container)
server:
  port: 8081
spring:
  datasource:
    username: "app_user"
```

> **NOTE:** The helm variable `{{ .Values.postres.auth.username }}` has been replaced accordingly

### Specifying both `app.config` and `app.rawConfig`

Both `app.config` and `app.rawConfig` can be specified simultaneously. Care must only be taken when the
same properties are defined through both properties. The configurations will be merged and all properties
configured through `app.config` will overwrite the values in `app.rawConfig`.

For example, if you have the following `values.yaml` file:

```yaml
# values.yaml
app:
  config:
    server:
      port: 9999
    spring:
      datasource:
        username: postgres
  rawConfig: |
    server:
      port: 8888
```

The resulting `application.yaml` file will look like this:

```yaml
# /opt/app/config/application.yaml (mounted in container)
server:
  port: 9999
spring:
  datasource:
    username: postgres
```

> **NOTE:** The `server.port` value specified underneath `app.rawConfig` would have no effect in this scenario.

## Traefik

Besides the well known `ingress.yaml` configuration that can be enabled, this chart supports installing
a traefik `IngressRoute` resource as well as a `Middleware` resource, in order to enable external
access to the service. This is a feature which is enabled by default.

```yaml
# values.yaml
ingressroute:
  # Enable installing the IngressRoute (true, by default)
  enabled: true
  # The path under which the service should be externally available (mandatory, if ingressroute.enabled is true)
  path: "/my-service"
```

The `IngressRoute` and `Middleware` will be preconfigured for the deployment:

- The `websecure` entrypoint will be used
- All routes containing an `internal` path part, will be disallowed
- The configured path (e.g., `.api/my-service`) will be stripped before sending the request to the target service

## Secrets

This helm chart supports kubernetes secrets through the `app.secrets` value. The specified secrets
will be mounted into the container underneath `/var/run/secrets/app/{secret-key}`. Then, on application
start, the mounted secrets will be read as spring boot application properties using the
`spring.boot.config` property with a value of `optional:configtree:/var/run/secrets/app/`. Here, the
`configtree` strategy is used. For more details on how this works, see
[Volume Mounted Configuration Trees](https://spring.io/blog/2020/08/14/config-file-processing-in-spring-boot-2-4#volume-mounted-configuration-trees)

For example, if you specify in your values.yaml:

```yaml
# values.yaml
app:
  secrets:
    - name: my-secret
```

and `my-secret` is defined as follows:

```yaml
# mysecret.yaml
type: Opaque
kind: Secret
apiVersion: v1
metadata:
  name: mysecret
stringData:
  spring.datasource.password: secret
  service.api-key: password
```

Then this will result in two files being mounted in the container:

```
var/
 +- run/
     +- secrets/
         +- app/
             +- spring.datasource.password
             +- service.api-key
```

The files `spring.datasource.password` and `service.api-key` will have their respective values
`secret` and `password` as content.

Through spring boots support of configuration import with `configtree`, this will now result in
the properties `spring.datasource.password` and `service.api-key` set accordingly.

### Multiple Secrets

Multiple secrets are supported by either specifying a single kubernetes secret and having multiple
`stringData` or `data` entries (as in the example above), or by simply listing all kubernetes secrets
that should be imported:

```yaml
# values.yaml
app:
  secrets:
    - name: my-secret
    - name: other-secret
```

### Excluding keys from a secret

Sometimes it might be necessary to only include a subset of `stringData` or `data`entries of a
kubernetes secret. This is supported by explicitly including the required keys:

```yaml
# values.yaml
secrets:
  - name: my-secret
    items:
      - key: spring.datasource.password
```

This would only mount `spring.datasource.password`, but not `service.api-key`.

### Renaming keys of a secret to match spring property names

Usually, the name of a key within a kubernetes secret must match a spring boot application property
in order to set that property correctly. However, this might not always be the case. For example,
if you have the following secret:

```yaml
# db-secret.yaml
type: Opaque
kind: Secret
apiVersion: v1
metadata:
  name: db-secret
stringData:
  PASSWORD: database-password
```

Then this cannot be used as it is, as it would set the spring boot `PASSWORD` property (which does not exist).
If we instead want to set `spring.datasource.password`, we can use the following configuration in our
`values.yaml` file:

```yaml
# values.yaml
secrets:
  - name: db-secret
    items:
      - key: PASSWORD
        path: spring.datasource.password
```

### Additional mount options

The configured secrets underneath `app.secrets` will be mounted through a single projected volume with
multiple sources of type `secret`. Therefore, you can specify the same options:

```yaml
# config options for a secret
secrets:
  - name: db-secret # the name of the kubernetes secret to be mounted
    optional: true # whether the secret must exist (false, by default)

    # only mount a subset of keys from the secret
    items:
      - key: PASSWORD # which key from the secret should be mounted
        path: spring.datasource.password # the new filename (must match a valid spring boot application property)
        mode: 511 # the mode for the mounted file (400, by default)
```

### Alternative as environment variable

* don't mount the secret
* configure it as env instead

```yaml
extraEnv:
  - name: "SPRING_DATASOURCE_PASSWORD"
    valueFrom:
      secretKeyRef:
        name: "db-secret"
        key: "PASSWORD"
```
