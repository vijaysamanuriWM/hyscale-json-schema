
# Hyscale Spec File Reference

> Version 1.0B <br /> Last Updated 13th September 2019

TABLE OF CONTENTS


[TOC]



### Overview

* The Hyscale Service Spec file is meant for user to declaratively describe the service/application and its related configuration.

* For environment related overrides/differences, specify a profile which can override certain service/app related configurations.

* Infra targets are specified in a infra conf which maintains the paths to various infra conf/creds such as:

```
        CLUSTER: Kubeconf 

	REGISTRY: Dockerconf

	ARTIFACT-REPO: Jenkinsconf/JfrogConf

	BUILDER: Kanikoconf
```

* Deployment of a service involves 3 inputs:
`
deploy -s <service-spec> -p <profile> -i <infra-conf>
`
  (command format & flags are only indicative)


### General Guidelines

*   Hyscale Spec File is a valid YAML file.
*   Works for any service be it bespoke, off-the-shelf, stateless, stateful, etc.
*   Abstracts Kubernetes concepts/knowledge with a simplified DSL.
*   Should be developer friendly and can be added to version control.
*   Any spec file should end with “.hspec.yaml” so that service specs can be easily identified
*   Filename  should be named exactly as per service name `<service-name>.hspec.yaml`
*   Multiple spec files can be present in a directory.
*   Support environment profiles (eg: dev, stage and prod etc.) Env props and customizations are in profile file. 
*   Profile files may mirror some of the fields given in the service spec. Only few fields allowed as indicated in this reference. Any fields specified in profile may get merged or override the ones given in spec, this behaviour is specified below for each field.
*   Supports camel case for keys.  Along with camel case, Uppercase for keys can be accepted in the future. In case of Uppercase,  multi-word keys are separated by underscore `(_)` delimiter.


### Reference Spec File with all options

```yaml

name: <service-name>                # should be same as in filename
depends: [<service-name1>, <service-name2>, … , <service-nameN>]
image:
    name:  <image-name>
    registry: <target-registry-url>
    tag: <tag>
    dockerfile:
        path: <build-context-path>               # default is ./
        dockerfilePath: <dockerfile-path>        # default is <path>/Dockerfile
        target: <stage-name>                     # default is final stage 
        args:
            <key1>:<value1> 
    buildSpec:
       stackImage: [<pull-registry-url>/]<stack-image-name>[:<stack-image-tag>]
       artifacts:
           - name: <artifact-name>
             provider: [http|ssh|local]          # default is local
             source: <url> #       http://xyz.com/abc/{{ buildNumber }}/login.war            # can have substitutions with place holders 
             destination: <destination-in-container>

       configScript: <config-commands-script>    # output of this script is baked inside image
       configCommands: |-
         <config-command1>
         [<config-command2>]
         .
         .
         [<config-commandN>]

       runScript: <run-commands-script>          # runs on container start
                                                 # can refer props as $prop-name
                                                 # CMD in dockerfile
       runCommands: |-
         # Executes while container start
         <run-command1>
        [<run-command2>]
         .
         .
        [<run-commandN>]

startCommand: <start-command with args>          # command+args in k8s yaml, overrides ENTRYPOINT+CMD
replicas: <replica-count>                        # default is 1
memory: [<min-memory>-]<max-memory> 
cpu: [<min-cpu>-]<max-cpu>

external: <true/false>
ports:
    - port: <port-number1>[/<port-type>]         # default type is tcp
      healthCheck:
          httpPath: <http-path>                  # default is false
      lbMappings:                                # optional
            host: <hostName>
            tls: <true/false>
            contextPaths:
                - path: <path>
            headers: 
                header1: value1
               [header2: value2]

   [- port: <port-number2>/<port-type>]

volumes:                        
    - name: <volume-name1>
      path: <volume-mount-path>
     [size: <size>]             # default size is 1G
     [storageClass: <storageClass>]

propsVolumePath: <volume-path-of-configmap> 
props: 
    <key1>: [<file/endpoint/string>(]<value1>[)]     # default type is string
   [<key2>: <value2>]
   .
   [<keyN>: <valueN>]

secrets:
    - <secret1>
    .
   [- <secretN>]

secretsVolumePath: <volume-path-of-secrets>
agents:
    - name: <sidecarName>
      image: [<pull-registry-url>/]<sidecar-image-name>[:<sidecar-image-tag>]
      props: 
          <key1>: [<file/endpoint/string>(]<value1>[)]
         [<key2>: [<file/endpoint/string>(]<value2>[)]
      volumes: 
          - path: <volume-mount-path1>
            name: <volume-name1>                    # use same name as service vol for sharing
           [readOnly: <true/false>]                 # readOnly is valid for shared volume
         [- path: <volume-mount-path2>
            name: <volume-name2>]
           [readOnly: <true/false>]        
```


### Example:


```yaml

name: hrms-frontend
image:
   name: gcr.io/hyscale-hrms/hrms-frontend:1.0
   dockerfile: {} # all default values
replicas: 1
volumes:
  - name: logs
    path: /usr/local/tomcat/logs
    size: 1g
  - name: data
    path: /data
    size: 2g
 
secrets:
  - keystore_password
 
props:
    max_conn: file(./config/config.xml)
    country: india
    region: hyderabad
    mysql_ost: endpoint(mysqldb)
    max_threads: 15
    server_xml: file(./config/tomcat/server.xml)
external: true
ports:
  - port: 8080/tcp
    healthCheck:
  	httpPath: /hrms
    
    lbMappings:
        - host: dev-hrms.com
  	  tls: true
  	  path: /hrms
  	  httpHeaders:
     	     header1: value1
     	     header2: value2

agents:
  - name: logging-agent
    image: gcr.io/test/logstash:2.2
    props:
    	FLUEND_CONF: file(./config/log/fluentd.conf)
    volumes:
        - path: /usr/local/tomcat/logs
  	  name: logs

profiles: # we can also write conditions to automatically activate one of the profile
# dev profile
- name: dev
  replicas: 2
  props:
 	country: us
 	region: california
 	max_threads: 20
 	server_xml: file(./config/tomcat/server.xml)

  volumes:
    - name: logs
      size: 2g
  agents:
    - $disable: true
      name: logging-agent

  ports:
     - port: 8080/tcp
       lbMappings:
           - host: dev-hrms.com

# stage profile
- name: stage
  replicas: 3
  props:
      country: india
      region: hyderabad
      max_threads: 10
      server_xml: file(./config/tomcat/server.xml)

  volumes:
    - name: logs
      size: 2g

  ports:
    - port: 8080/tcp
      lbMappings:
        - host: stage-hrms.com
```

### 


### Field Reference


<table>
  <tr>
   <td><strong>Field</strong>
   </td>
   <td><strong>Type</strong>
   </td>
   <td><strong>default</strong>
   </td>
   <td><strong>Explanation</strong>
   </td>
  </tr>
  <tr>
   <td><a href="#image">image</a>
   </td>
   <td>struct
   </td>
   <td>
   </td>
   <td>Can’t be overridden
<p>
Describes an image to be deployed.
<p>
image section contains following:
<ol>

<li>name and tag

<li>Registry url where the image resides

<li>dockerfile or buildSpec fields
</li>
</ol>
   </td>
  </tr>
  <tr>
   <td>replicas
   </td>
   <td>int
   </td>
   <td>1
   </td>
   <td>Optional
<p>
Can be overridden
<p>
Number of instances of the service
   </td>
  </tr>
  <tr>
   <td>memory
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Optional
<p>
Can be overridden
<p>
Specify the range 
<p>
[<minMemory>-]<maxMemory>
<p>
Eg: 512m-1024m or 512m
   </td>
  </tr>
  <tr>
   <td>cpu
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Optional
<p>
Can be overridden
<p>
Specify the cpu range 
<p>
[<minCpu>-]<maxCpu>
<p>
Eg: 60-80 or 50
   </td>
  </tr>
  <tr>
   <td>startCommand
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Optional
<p>
Can’t be overridden
<ul>

<li>startCommand is a command which gets executed at the time of container start

<li>it includes both ENTRYPOINT and CMD separated by space delimiter

<li>User may refer to the runCommandsScript above in CMD
</li>
</ul>
   </td>
  </tr>
  <tr>
   <td><a href="#ports">ports</a>
   </td>
   <td>list
   </td>
   <td>
   </td>
   <td>Can be overridden
<p>
List of ports to be declared along with externalize, healthcheck and ingressrules if any.
   </td>
  </tr>
  <tr>
   <td>props
   </td>
   <td>list 
   </td>
   <td>
   </td>
   <td>Optional
<p>
Can be overridden
<p>
<keyName>:[<file/endpoint/string>(]<value>[)]
<ul>

<li>List of key value pairs

<li>Value is typed and can be of type: string, file, endpoint

<li>DEFAULT type is string

<p>
Eg:
<p>
props:
<p>
   MAX_NO_OF_CONNECTIONS: STRING(10)
<p>
   MYSQL_HOST=ENDPOINT(mysql)
<p>
   KEY_FILE=FILE(/tmp/file.txt)
</li>
</ul>
   </td>
  </tr>
  <tr>
   <td>secrets
   </td>
   <td>list
   </td>
   <td>
   </td>
   <td>Optional   Can be overridden
<p>
<secretKeyName>
<p>
List of secret key Names
<p>
Eg:
<p>
secrets:
<p>
- "MYSQL_ROOT_PASSWORD"
   </td>
  </tr>
  <tr>
   <td><a href="#volumes">volumes</a>
   </td>
   <td>list
   </td>
   <td>
   </td>
   <td>Optional Can be overridden
<p>
List of volumes to be specified in a pod.
   </td>
  </tr>
  <tr>
   <td><a href="#agents">agents</a>
   </td>
   <td>list
   </td>
   <td>
   </td>
   <td>Optional Can be overridden
<p>
List of sidecars to be attached to the pod
   </td>
  </tr>
</table>


### image

Following are the fields of image section.


<table>
  <tr>
   <td><strong>Field</strong>
   </td>
   <td><strong>Type</strong>
   </td>
   <td><strong>default</strong>
   </td>
   <td><strong>Explanation</strong>
   </td>
  </tr>
  <tr>
   <td>name
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Name of the image to be built 
<p>
Note: retagging should be done for the already provided image
   </td>
  </tr>
  <tr>
   <td>tag
   </td>
   <td>string
   </td>
   <td>latest
   </td>
   <td>Tag would be overridden if tagpolicy is mentioned 
   </td>
  </tr>
  <tr>
   <td>registry
   </td>
   <td>string
   </td>
   <td>docker.io/library
   </td>
   <td>registry url along with the namespace
   </td>
  </tr>
  <tr>
   <td><a href="#buildspec">buildSpec</a>
   </td>
   <td>struct
   </td>
   <td>
   </td>
   <td>Optional generate Docker and build with local docker daemon
   </td>
  </tr>
  <tr>
   <td><a href="#dockerfile">dockerfile</a>
   </td>
   <td>struct
   </td>
   <td>
   </td>
   <td>Optional build with Dockerfile using local docker daemon 
   </td>
  </tr>
  <tr>
   <td>tagPolicy
<p>
<em>(future, currently unspecified)</em>
   </td>
   <td>struct
   </td>
   <td>sha256
   </td>
   <td>Optional
<p>
Supports following tag policies
<ul>

<li>Gitcommit 

<li>sha256

<li>dateTime
</li>
</ul>
   </td>
  </tr>
</table>


#### Builders:

Hyscale supports following to build your image:

*   hyscaleBuildSpec locally with Docker
*   Dockerfile with local docker

> Note: 
Following additional building mechanisms can be supported in future: <br />
Dockerfile with kaniko in-cluster <br />
jib maven and gradle projects locally <br />
bazel locally <br />
Cloud-native build packs <br />

## buildSpec

HyscaleBuildSpec locally with Docker

<table>
  <tr>
   <td><strong>Option</strong>
   </td>
   <td><strong>Type</strong>
   </td>
   <td><strong>default</strong>
   </td>
   <td><strong>Explanation</strong>
   </td>
  </tr>
  <tr>
   <td><a href="#stackImage">stackImage</a>
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Stack indicates the base image on top of which artifacts and configuration is layered.
   </td>
  </tr>
  <tr>
   <td><a href="#artifacts">artifacts</a>
   </td>
   <td>list
   </td>
   <td>
   </td>
   <td>Optional Represents the list of artifacts to be present inside the container at defined destinations.
   </td>
  </tr>
  <tr>
   <td><a href="#configCommandsScript">configCommandsScript</a>
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Optional path-to-script relative or absolute path to a config-Commands script
   </td>
  </tr>
  <tr>
   <td>configCommands
   </td>
   <td>list
   </td>
   <td>
   </td>
   <td>Optional Array of commands which is invoked during image build. The commands are also part of the image.
   </td>
  </tr>
  <tr>
   <td><a href="#runScript">runScript</a>
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Optional path-to-script relative or absolute path to a run-Commands script
   </td>
  </tr>
  <tr>
   <td>runCommands
   </td>
   <td>list
   </td>
   <td>
   </td>
   <td>Optional runCommand is a command which gets executed at the time of container start and is baked into the image
   </td>
  </tr>
</table>


### stackImage

`
	stack: [<registryUrl>/]<image>[:<tag>]
`

*   Stack indicates the base image on top of which artifacts and configuration is layered.
*   registryUrl is optional.
*   tag or digest is optional. latest is assumed.

   

   Eg: 

```yaml
   stackImage: tomcat:8.5
```

### artifacts

> can be overridden

```yaml
    artifacts:
      - name: <artifactName1>
      	destination: <destination1InContainer>
      	provider: [ssh/http/local]                  # default local
           source: <url>
```
                      

#### Fields:


<table>
  <tr>
   <td><strong>Option</strong>
   </td>
   <td><strong>Type</strong>
   </td>
   <td><strong>default</strong>
   </td>
   <td><strong>Description</strong>
   </td>
  </tr>
  <tr>
   <td>name
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Name of the artifact
   </td>
  </tr>
  <tr>
   <td>destination
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Destination path to copy the artifact inside the container
   </td>
  </tr>
  <tr>
   <td>provider
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Optional type of provider. Could be one of:
<ul>

<li>local  
<ul>
 
<li>Artifact available locally
 
<li>Relative path to the artifact is expected in the source field
</li> 
</ul>

<li>ssh 
<ul>
 
<li>Artifact available remotely 
 
<li>Accessible through ssh
 
<li>Auth credentials can be mentioned in infrastructure spec
 
<li>source is ssh url
</li> 
</ul>

<li>http 
<ul>
 
<li>Artifact available remotely
 
<li>Accessible through http
 
<li>Auth credentials can be mentioned in infrastructure spec
 
<li>Source is http url

<p>
 
</li> 
</ul>
</li> 
</ul>
   </td>
  </tr>
  <tr>
   <td>source
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Url to the artifact
   </td>
  </tr>
</table>


*   List of artifacts to be copied inside the container image
*   Copies the artifact mentioned in sourcePath of local folder to destinationPath inside image
*   Artifact can be from one of the following sources:
*   local
*   Remote (like jfrog, jenkins etc..)

### _configCommandsScript_

> Optional  _string type_

*   Path to a Script containing config commands.
*   It is mutually exclusive with configCommands field. 
*   If configCommands is given and not empty configCommandsScript has no effect. 

### runScript

> Optional  _string type_



*   Path to a Script containing runConfig commands.
*   It is mutually exclusive with runCommands field. 
*   If runCommands is given and not empty runCommandsScript has no effect. 

### dockerfile

Use local docker to build docker image with the given Dockerfile

```yaml
   docker:
  	[buildContext: <buildContext>] #incase buildspecPath is given
  	target: <target>
  	useBuildKit: <true/false>
  	buildArgs:
  	    - <buildarg1>

           [- <buildarg2>]

            .

	    .

          [- <buildargN>]
```

<table>
  <tr>
   <td><strong>Option</strong>
   </td>
   <td><strong>Type</strong>
   </td>
   <td><strong>default</strong>
   </td>
   <td><strong>Explanation</strong>
   </td>
  </tr>
  <tr>
   <td>path
   </td>
   <td>string
   </td>
   <td>./
   </td>
   <td>Optional buildContext for docker build
   </td>
  </tr>
  <tr>
   <td>dockerfilePath
   </td>
   <td>string
   </td>
   <td>./Dockerfile
   </td>
   <td>Optional dockerfile path with in the build context
   </td>
  </tr>
  <tr>
   <td>target
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Optional target stage to be built
   </td>
  </tr>
  <tr>
   <td>useBuildKit
   </td>
   <td>boolean
   </td>
   <td>
   </td>
   <td>Optional Use buildkit 
   </td>
  </tr>
  <tr>
   <td>buildArgs
   </td>
   <td>list
   </td>
   <td>
   </td>
   <td>Optional List of build arguments to be passed
   </td>
  </tr>
</table>


Eg:

```yaml
   dockerfile:
  	path: ./
        dockerfilePath: Dockerfile.build
  	target: finalstage
  	useBuildKit: false
  	buildArgs:
           - foo=value1
  	   - bar=value2
```

### ports

List of port objects.

```yaml
ports:
  - port: <portNumber1>[/<portType>]
    healthcheck:
       httpPath: <httpPath> # optional if not http type
    external: <true/false> # optional default false
    lbMappings: #optional
      - host: <hostName>
        path: <path>
        tls: <true/false>
        httpHeaders:
           header1: value1
          [header2: value2]

  [- port: <portNumber2>/<portType>]
```

**Port Object contains:**

*   port to be declared in a pod
*   healthcheck if available for the port to be specified along with the port definition
*   If you want to externalize this port use _external_ flag
*   If there are associated ingress rules for the port specify them.

> Note:
Currently Health Check would be present for only one port if any.       


Following are the **Fields** of Port object:


<table>
  <tr>
   <td><strong>Option</strong>
   </td>
   <td><strong>Type</strong>
   </td>
   <td><strong>default</strong>
   </td>
   <td><strong>Explanation</strong>
   </td>
  </tr>
  <tr>
   <td>port
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td><portNumber>[/<portType>]
<ul>

<li>portNumber Port Number to be  declared in pod 0-65535

<li>portType tcp/udp
</li>
</ul>
   </td>
  </tr>
  <tr>
   <td>healthCheck
   </td>
   <td>struct
   </td>
   <td><strong>http</strong> incase healthCheckPath is given, <strong>tcp</strong> if nothing given 
   </td>
   <td>Optional
<p>
healthcheck:
<p>
      type: <tcp/http/udp> # optional
<p>
      httpPath: <httpPath> # optional if not type: http
<p>
<strong>type</strong>
<p>
Type string Optional
<p>
Type of HealthCheck for the specified port
<ul>

<li>tcp 

<li>Udp

<li>http 

<p>
<strong>http</strong> incase httpPath is given, <strong>tcp</strong> if nothing given
<p>
<strong>Note:</strong>
<p>
exec/command healthchecks should be mentioned in a separate section
<p>
<strong>httpPath</strong>
<p>
Type string Optional 
<p>
http Path for http health check
<p>
Eg: httpPath: /hrms
<p>
Eg:
<p>
 healthcheck:
<p>
   httpPath: /hmrs
</li>
</ul>
   </td>
  </tr>
  <tr>
   <td>external
   </td>
   <td>string
   </td>
   <td>false
   </td>
   <td>Optional
<p>
<true/false>
<ul>

<li>Exposes the specified port externally. 

<li>External IP would be assigned.
</li>
</ul>
   </td>
  </tr>
  <tr>
   <td>lbMappings
   </td>
   <td>list
   </td>
   <td>
   </td>
   <td>Optional
<p>
List of Ingress rules for the specified por
<p>
Ingress Rule contains the following fields:
<p>
<strong>host</strong> hostname 
<p>
<strong>path </strong>regex path Mapping
<p>
<strong>tls</strong> enable ssl
<p>
<strong>httpHeaders </strong>http headers if any
<p>
Eg:
<p>
lbMappings:
<p>
- host: login.app.com
<p>
  path: /login
<p>
  Tls: true
<p>
  httpHeaders:
<p>
     X-DOMAIN_LOGIN: value
<p>
- host: launchpad.app.com
<p>
  path: /launchpad
   </td>
  </tr>
</table>


Eg:
```yaml
    ports:
      - port: 8080/TCP
  	healthCheck:
  	    httpPath: "/hrms" # optional
        external: true # optional default false
        lbMappings:
  	  - host: {{ HOST }}
    	    path: /hrms

      - port: 8008/TCP
```


### volumes

List of volume Objects.

```yaml
  volumes:# optional can be inferred from docker inspection and default 2 GB + default sc
    - name: <volumeName1>
      path: <volumeMountPath>
     [sizeInGB: <sizeInGB>]
```

**volume Object contains:**

*   name of volume
*   path mount Path inside container
*   sizeInGB volume size in GB to provision using environment defined storage class.

`
**Note:**

volumes referring other volumes is _future, currently unspecified_
`

Following are the **Fields** in dataPath object

<table>
  <tr>
   <td><strong>Option</strong>
   </td>
   <td><strong>Type</strong>
   </td>
   <td><strong>default</strong>
   </td>
   <td><strong>Explanation</strong>
   </td>
  </tr>
  <tr>
   <td>name
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Name of volume
<p>
should be up to maximum length of 253 characters and consist of lower case alphanumeric characters, -, and ., but certain resources have more specific restrictions.
<p>
Eg:
<p>
name: logsDirectory
   </td>
  </tr>
  <tr>
   <td>path
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Mount Path of the volume inside container 
<p>
Eg:
<p>
path: /usr/local/tomcat/logs
   </td>
  </tr>
  <tr>
   <td>size
   </td>
   <td>string
   </td>
   <td>2
   </td>
   <td>Optional
<p>
Size of volume to be provisioned
<p>
Makes use of environment tied kubernetes storage class to provision volume.
<p>
Eg: size: 1g
   </td>
  </tr>
</table>


Eg:


```yaml
volumes:
  - name: tomcat-logs
    path: /usr/local/content/tomcat/current/logs
    size: 1g

  - name: data
    path: /usr/local/content/tomcat/current/webapps
```

### agents

List of agent (aka sidecar) objects.

```yaml
  agents:
  - name: <sidecarName>
    image: <sidecarWithVersion>
    props:
    - "<sidecarKey1Name>=<file/endpoint/string>(<sidecarValue1>)"
    [- "<sidecarKey2Name>=<file/endpoint/string>(<sidecarValue2>)"]
    volumes: 
    - path: <sidecarVolumeMountPath1>
      name: <sidecarVolumeName1>

   [- path: <sidecarVolumeMountPath2>
      name: <sidecarVolumeName2>]
```

**Agent Object contains:** 

*   _name_ of sidecar attachment
*   _image_ sidecar image full name
*   _props_ list of env including secrets
*   _volumes list of volumes_

Following are the **fields** of agent object:


<table>
  <tr>
   <td><strong>Option</strong>
   </td>
   <td><strong>Type</strong>
   </td>
   <td><strong>default</strong>
   </td>
   <td><strong>Explanation</strong>
   </td>
  </tr>
  <tr>
   <td>name
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>Name of sidecar Attachment
<p>
should be up to maximum length of 253 characters and consist of lower case alphanumeric characters, -, and ., but certain resources have more specific restrictions.
<p>
Eg:
<p>
name: fluentd
   </td>
  </tr>
  <tr>
   <td>image
   </td>
   <td>string
   </td>
   <td>
   </td>
   <td>sidecar with version
<p>
Eg:
<p>
sidecar: fluentd:5.6
   </td>
  </tr>
  <tr>
   <td>props
   </td>
   <td>list
   </td>
   <td>2
   </td>
   <td>Optional
<p>
<sidecarenvkeyName>=[<file/endpoint/string>(]<value>[)]
<ul>

<li>List of key value pairs

<li>Value is typed and can be of type: string, file, endpoint

<li>DEFAULT type is string

<p>
Eg:
<p>
props:
<p>
- "FLUENTD_ARGS=--no-supervisor -vv"
<p>
- "system.input.conf=file(/system.input.conf)"
<p>
- "output.conf=file(/tmp/output.conf)"
</li>
</ul>
   </td>
  </tr>
  <tr>
   <td>volumes
   </td>
   <td>list
   </td>
   <td>
   </td>
   <td>List of volumes to be declared for a sidecar
   </td>
  </tr>
</table>



### 


### Spec Template File

For Off-the-Shelf (OTS) services as well as for commonly used configurations of known services, spec template files could be made available as a starting point. Once a spec template is downloaded for use, it can be extended to create a service spec (hspec) in order to override commonly specified configurations. 

For example, a mysql spec template may include things like 3306 for ports, /var/lib/mysql/ as a volume path, etc. Anyone extending this template to create their hspec may wish to override things like the password secret, etc.

The following rules apply to a spec template:

1. Spec templates are valid YAML files.
2. Spec template end with the extension “htpl.yaml”
3. A template file must include a “name” and “version” attribute. Name is same as in the filename of the template. Name & version would be used in the hspec which extends.
4. The filename of the spec template should be same as the service name + version. Eg. “<service-name>-<version>.htpl.yaml”
5. A template file may include any of the fields that a regular hspec can have, except as per the following. 
6. A template file cannot include:
    1. buildSpec & dockerSpec
    2. ports->external and ports->lbMappings

        ```
NOTE: Consideration for future versions of spec templates:
Spec Templates as bundles (htpl.tar)
This enables things like artifacts, dockerfiles, config files, etc. to be included in the htpl bundle.
This will enable support for buildSpec and dockerSpec.
The bundle could be name.htpl.tar which expands and should mandatorily include name.htpl.yaml
Allow remote spec template repositories & corresponding spec
```



**Extending a Spec Template (htpl) into a Service Spec (hspec)**

In a service spec, use the “extends” field as follows:


    **extends**: <service-template-name>:<template-version>

In the hspec, any **props, secrets, volumes, ports** specified are merged or overridden if having same keyname. 

“**image**” is overridden if specified in hspec, and the “image” given in the htpl is used as stack image within the buildSpec.


```
Future versions may support:
Specifying a remote URL in the extends field
$remove: <key-name> in the hspec in order to skip that key & corresponding sub-tree from the htpl
Consider extending multiple htpl files in a single hspec file
```



### Profile Files 

In order to deploy a service into different environments (such as QA, Stage, UAT, etc.), it maybe necessary to override certain fields to customize as per that environment. This is supported by the use of profile files.

A profile file may override a spec file by specifying the following:

**environment**: <profile-name>

**overrides**: <service-name>

Profile files should be “<service-name>.<profile-name>.yaml”

The following fields of service spec can be overridden or additionally specified (merged) in a profile file:

**props, secrets, replicas, resource-limits, size of volumes **and** agents**

_(overrides if same keyname)_


```
Future versions may support:

Disabling of agents or healthChecks using an additional field in the relevant section such as:
$disable: true
```
