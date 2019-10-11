# HyScale
### The k8s Deployment Tool Command Line Interface

HyScale is an app deployment tool for deploying apps to Kubernetes quickly without having to learn k8s concepts or write & maintain k8s manifests. It provides a convenient CLI for deploying, viewing status, logs and undeploying. It includes a declarative service spec parser for k8s abstraction and the automatic generation of k8s manifests & docker files.

See documentation [here](docs/https://hyscale.github.).

## Installation

Open your terminal and enter the following:

    $ curl -s https://get.hyscale.io | bash

Currently tested on Linux only.

## Deploying to k8s

### Before you start

In order to deploy your service to k8s, you must have the kube config file with the cluster token placed at $HOME/.kube/config and your image registry credentials at $HOME/.docker/config.json

### Preparing your first service spec

Here is a small service spec that works for a basic java app. For all possible options, see the [spec reference](docs/hyscale-spec-reference.md).

```yaml
NAME: my-service
Image:
    registry: registry.hub.docker.com/library
name: tomcat
 
volumes:
     -path: /usr/local/tomcat
      size: 1Gi
 
PORTS:
    - NAME: tomcat-port
      PORT: 8080/tcp
      HEALTH_CHECK:
          TYPE: tcp
```

### Deploy the service

To deploy, invoke the hyscale deploy command:
hyscale deploy service -f <my-service-spec.yaml> -n <my-namespace> -a <my-app-name>

To view the status of your deployment:
hyscale get service status -s <my-service-name> -n <my-namespace> -a <my-app-name>

To view logs:
hyscale get service logs -s <my-service-name> -n <my-namespace> -a <my-app-name>

For all possible commands, see the [command reference](docs/hyscale-commands-reference.md).

### Local compilation

To compile hyscale from source, run the following commands:

    $ mvn clean install


## Future development

Some interesting possiblities for the future include…
1)
2)
3)

These are spec'ed out here within HEPs (HyScale Enhancement Proposals) and a full list can be found [here](https://hyscale.github.com/heps).

