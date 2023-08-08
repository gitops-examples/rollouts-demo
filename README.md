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
- kubectl rollouts plugin

OpenShift cluser must have:

- OpenShift GitOps 1.9+
- OpenShift Pipelines 1.11+

### Installing the Demo

Note that this demo is assuming it is being installed in a lab or test cluster where the user has full access to the openshift-gitops namespace.

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

* Validate that the applications have been deployed and installed in Argo CD, the demo will install a separate Argo CD instance in the rollouts-demo-gitops namespace. To simplify the demo, note this instance
is configured so that any user that can authenticate through OpenShift will be granted *admin rights*.

![alt text](https://raw.githubusercontent.com/gitops-examples/rollouts-demo/main/docs/img/argo-cd-apps.png)

- Validate that the bluegreen and canary rollouts are running in rollouts-demo-prod and the provided routes work. The app displays a set of colored squares based on the currently deployed image, the demo initially provisions
the blue image and will appear as below. As each square lights up this reflects a request made to the apps back-end and the color shown is reflective of this as we will see later.

![alt text](https://raw.githubusercontent.com/gitops-examples/rollouts-demo/main/docs/img/rollout-app.png)

### User Interface

When running the demo you will typically want to have a UI in order to follow the flow and interact with rollouts visually. You have two choices for UI at this time:

* The local rollouts UI can be run from your laptop and access the UI in your browser at localhost:3100, the included script `rollouts-dashboard.sh` will do this for you.

* There is an experimental OpenShift GitOps openshift dynamic console plugin that also provides a UI for rollouts. See more info about it and how to install it [here](https://github.com/gnunn-gitops/gitops-admin-plugin).

### Demo Flow

The demo consists of a pipeline that will promote a new image across the `rollouts-demo-dev` and `rollouts-demo-prod` namespaces. In the dev namespace we have a simple Deployment whereas in prod we have both a bluegreen and canary rollout. When promoting the image into prod both the bluegreen and canary will be updated at the same time giving you an opportunity to compare and contrast the two strategies.

![alt text](https://raw.githubusercontent.com/gitops-examples/rollouts-demo/main/docs/img/pipeline.png)

To start the demo, run the pipeline located in the `rollouts-demo-cicd` namespace. You need to specify the color you want to deploy, i.e. `green` (but others are available as well), and specify a PVC for the manifests workspace. The following screenshot shows how to start the pipeline.

![alt text](https://raw.githubusercontent.com/gitops-examples/rollouts-demo/main/docs/img/start-pipeline.png)