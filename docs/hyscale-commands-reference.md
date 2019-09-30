
**Tool Command structure**



1.  _hyscalectl deploy service -f <serviceName>.hspec … 
      -n <nameSpace>  -a <applicationName> [-v]_

2. _hyscalectl undeploy service -s <serviceName> …_
        _-n <nameSpace>_
        _-a <applicationName> _


        (OR)


    _  hyscalectl undeploy app _
        _-n <nameSpace>_ _-a <applicationName>_


3. _hyscalectl generate service manifests  -s <serviceName>_
        _-n <nameSpace>_      _-a <applicationName>_

4. _hyscalectl get service logs -s <serviceName> ..._ _-n <nameSpace>_ _-a <applicationName> [-l <lines>] [-t]_

5. _hyscalectl get service status  -s <serviceName>]  … _ _-n <nameSpace>_ _-a <applicationName>_

6. _hyscalectl get app status  -n <nameSpace> -a <applicationName>_

**Tool Options Description**


    _-f <serviceName>.hspec_  HyScale Service Spec file where file name should be same as service name mentioned inside spec. This is the name with which service by default gets deployed


    _-n <nameSpace>  _           Kubernetes namespace where service is deployed


    _-a <applicationName>  _    Logical grouping of services to-gether with give application name. 


    _-p <environment>.yaml _    Environment profile file where single or multiple profile props can be defined.


