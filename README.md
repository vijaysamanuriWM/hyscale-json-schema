# HyScale
### The k8s Deployment Tool 

HyScale is an app deployment tool for deploying apps to Kubernetes quickly without having to learn k8s concepts or write & maintain k8s manifests. It provides a convenient CLI for deploying, viewing status, logs and undeploying. It includes a declarative service spec parser for k8s abstraction and the automatic generation of k8s manifests & docker files.

See documentation [here](docs/developer-guide.md).

## Installation

Open your terminal and enter the following:

    $ curl -s https://get.hyscale.io | bash

## Limitations
Works for linux environments

## Prerequisites
In order to deploy your service to k8s, you must have the following configurations and installations in place
1. Docker 18.09.x and above versions  
2. kube config file with the cluster token placed at $HOME/.kube/config
3. Image registry credentials at $HOME/.docker/config.json (make sure `config.json` has the latest auth creds by logging into the image registry using `docker login` prior to deployment)

## Deploying to k8s
### Preparing your first service spec

Here is a small service spec that works for a basic java app. For all possible options, see the [spec reference](docs/hyscale-spec-reference.md).

```yaml
name: myservice
image:
    registry: registry.hub.docker.com/library
    name: tomcat
    tag: 8.5.0-jre8
 
volumes:
    - name: tomcat-logs-dir
      path: /usr/local/tomcat/logs
      size: 1Gi
      storageClass: standard
 
external: true
ports:
  - port: 8080/tcp
    healthCheck:
       httpPath: /docs/images/tomcat.gif

```

### Deploy the service

To deploy, invoke the hyscale deploy command:
hyscale deploy service -f <my-service.hspec.yaml> -n <my-namespace> -a <my-app-name>

To view the status of your deployment:
hyscale get service status -s <my-service> -n <my-namespace> -a <my-app-name>

To view logs:
hyscale get service logs -s <my-service> -n <my-namespace> -a <my-app-name>

For all possible commands, see the [command reference](docs/hyscale-commands-reference.md).

## Future development

Some interesting things for the future include…
*  Enabling developer collaboration in deployments by integrating user identity in deployments and validating the deployments when collaborated with others.
* Enhancements in troubleshooting deployment failures by providing more insights in the status command when deployments fails at kubernetes.
* Introducing profiles for deploying to various environments ie when any of the service spec attributes change with respect to the environment ( like production needs more memory & cpu than developer environments ) will be handled with profiles . Service spec will be merged with profile to obtain the effective service spec for that deployment.
* Service spec start off made easy with templates . Templates are mainly for standard services like (apache, elasticsearch, nginx, kafka, redis etc) which adds for reusability of services . Any customization can be added on top of templates which reduces the pain of writing the entire service spec.
* Cluster management where deployments can be made to multiple clusters with the handle of deployment option.
* Customized plugins for manifest generation, contributors can just add a plugin in manifest generation to satisfy the unsatisfied resources in the tool.
* Enhancing troubleshooting control with agents which are deployed as a sidecar along with the primary service to help efficient debugging of the application’s service.
* Handoff the load balancer from developer to kubernetes using ingress, developers need not worry about load balancing , configuring them etc , making it easy with kubernetes ingress.
* Seamless Local deployments with minikube / Kind: Providing minikube & kind installers along with the tool so that user can try immediately some deployments to kubernetes with the tool.

