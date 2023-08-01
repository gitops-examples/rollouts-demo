Note WIP

### Introduction

This is a demonstration of Argo Rollouts integrated with Argo CD in a standard OpenShift without a Service Mesh installed. The demo
includes a pipeline that can be used to switch between images by using tags (blue, green, yellow, etc) and the pipeline will
update the image references in the development and production namespaces.

In development a normal Deployment is used, in Production both a bluegreen and canary rollout for the same application is deployed
so that both strategies supported by Rolouts can be shown.

### Installing the Demo

Note that this demo is assuming it is being installed in a lab or test cluster where the user has full access to the openshift-gitops namespace.

* Install the OpenShift GitOps operator

* Fork this repo into your own space, this is required since the pipeline will update the repo with the new image references

* In `argocd\base\values.yaml` update the repoURL to use your forked repo

* Update the route parameters in `apps/overlays/bluegreen/rollout.yaml` and `apps/overlays/canary/rollout.yaml` so the subdomain (i.e. apps.<cluster-name>.<domain>) reflects
your cluster. This is needed since the demo uses Apache siege to generate load against the rollouts to support the Analysis.

* Log into OpenShift with the oc CLI and run the `bootstrap.sh` command to install the apps.

* Create a secret for github as follows replacing XXX with the appropriate values for your forked repository.

```
oc create secret generic test  --type='kubernetes.io/basic-auth' --from-literal=username=XXXX --from-literal=password=XXXX --from-literal=email=XXXXX -n rollouts-demo-cicd
```
