#HyScale Tool Command Reference

Version 1.0B

Last Updated 30th September 2019



## deploy

```markdown
Usage:  hyscale deploy service [OPTIONS] 

Deploy an application service

Options:
  -f, --file string    <serviceName>.hspec service spec file
  -n, --namespace string     namespace name
  -a, --application string   Application Name
  -v  --verbose     optional verbose mode
```

    To deploy an application service which is defined in the hspec file, use the "deploy" command. The command requires hspec file, Kubernetes namespace and the application name as  inputs.  Multiple hspec files (-f <serviceName1>.hspec -f <serviceName2>.hspec <serviceNameN>.hspec) can be provided to deploy multiple services.
