Note WIP

### Introduction

This is a demonstration of Argo Rollouts integrated with Argo CD in a standard OpenShift without a Service Mesh installed. The demo
includes a pipeline that can be used to switch between images by using tags (blue, green, yellow, etc) and the pipeline will
update the image references in the development and production namespaces.

In development a normal Deployment is used, in Production both a bluegreen and canary rollout for the same application is deployed
so that both strategies supported by Rolouts can be shown.

### Pre-requisites

Your local machine must be able to run a bash script and have the following command line tools available to it:
- envsubst
- git
- kustomize

### Installing the Demo

Note that this demo is assuming it is being installed in a lab or test cluster where the user has full access to the openshift-gitops namespace.

* Install the OpenShift GitOps and Pipelines operators in your cluster. Note GitOps 1.9+ and Pipelines 1.11+ is required

* Fork this repo into your own space, this is required since the pipeline will update the repo with the new image references

* Clone the forked repo to your local file system and then switch to the directory:

```cd rollouts-demo```

* Log into OpenShift with the oc CLI and from the `rollouts-demo` directory run the `bootstrap.sh` command to install the app.

* Create a secret for github as follows replacing XXX with the appropriate values for your forked repository, note the password is not your password to
github but a Personal Access Token (classic) that you need to create in github.

```
oc create secret generic github --type='kubernetes.io/basic-auth' --from-literal=username=XXXX --from-literal=password=XXXX --from-literal=email=XXXXX -n rollouts-demo-cicd
oc annotate secret github tekton.dev/git-0='https://github.com'  -n rollouts-demo-cicd
```
