### Introduction

This is a demonstration of Argo Rollouts integrated with Argo CD in a standard OpenShift environment without a Service Mesh installed. The demo
includes a pipeline that can be used to promote images using color coded tags (blue, green, yellow, etc) and the pipeline will
update the image references in the development and production namespaces via Argo CD.

In development a normal Deployment is used, in Production both a bluegreen and canary rollout for the same application is deployed
so that both strategies supported by Rollouts can be shown.

### Pre-requisites

Your local machine must be able to run a bash script and have the following command line tools available to it:
- envsubst
- git
- kustomize
- kubectl rollouts plugin

OpenShift cluser must have:

- OpenShift GitOps 1.11+
- OpenShift Pipelines 1.11+

### Installing the Demo

Note that this demo assumes it is being installed in a lab or test cluster where the user has full access to the openshift-gitops namespace. This process has been tested in RHDP using the OpenShift Workshop 4.13 catalog item.

* Fork this repo into your own space, this is required since the pipeline will update the repo with the new image references

* Clone the forked repo to your local file system and then switch to the directory:

```cd rollouts-demo```

* Log into OpenShift with the oc CLI and from the `rollouts-demo` directory run the `bootstrap.sh` command to install the app.

* Create a secret for github as follows replacing XXX with the appropriate values for your forked repository, note the password is not your password to
GitHub but a Personal Access Token (classic) that you need to create in GitHub.

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

* There is an experimental OpenShift GitOps openshift dynamic console plugin that also provides a UI for rollouts. See more info about it and how to install it see [here](https://github.com/gnunn-gitops/gitops-admin-plugin).

*Note*: If you are using RHDP for this demo and want to try the console plugin, make sure to select an instance that supports 3 control plane nodes otherwise the plugin will not rollout due to a bug in the console.

*Important*: The console plugin is not recommended for production instances at this time as only minimal testing as been done with it.

### Demo Flow

The demo consists of a pipeline that will promote a new image across the `rollouts-demo-dev` and `rollouts-demo-prod` namespaces. In the dev namespace we have a simple Deployment whereas in prod we have both a bluegreen and canary rollout. When promoting the image into prod both the bluegreen and canary will be updated at the same time giving you an opportunity to compare and contrast the two Rollout strategies.

![alt text](https://raw.githubusercontent.com/gitops-examples/rollouts-demo/main/docs/img/pipeline.png)

To start the demo, run the pipeline located in the `rollouts-demo-cicd` namespace. You need to specify the color you want to deploy, i.e. `green` (but others are available as well), and specify the `manifests` PVC for the manifests workspace. The following screenshot shows how to start the pipeline.

![alt text](https://raw.githubusercontent.com/gitops-examples/rollouts-demo/main/docs/img/start-pipeline.png)

Once the pipeline has completed, check the status of your rollouts and they should either be in the `Paused` or `Progressing` state as per the screenshot below (Console plugin, rollouts UI will look different):

![alt text](https://raw.githubusercontent.com/gitops-examples/rollouts-demo/main/docs/img/post-status.png)

Both rollouts have AnalysisRuns associated with them, the AnalysisRun does the following:

* Generates load on the application using the Apache siege application

* Examines metrics for the route to ensure responses are returning 200 rather then 400s or 500s

It can take some time for the AnalysisRun to complete and while it is running the bluegreen rollout state may be Progressing, wait until both rollouts are *Paused*.

At this point you can examine each rollout, you should see that the bluegreen has one revision set to `Preview` and the other set to `Active` and `Stable`. There are corresponding routes for each service, confirm that Preview is displaying green squares and active is displaying blue squares.

![alt text](https://raw.githubusercontent.com/gitops-examples/rollouts-demo/main/docs/img/blue-green-paused.png)

Next if you look at the canary one, you will see that the one service is designated as `Stable` and the other as `Canary`. Similar to blue green, if you check the corresponding routes you should see that Stable is displaying blue squares and canary is displaying green squares.

One other route to note for canary is `canary-all`. If you look at that route you will see it mostly displays blue squares with a small number of green squares being shown. The `canary-all` selects all pods hence why you see both and when Rollouts is used without a traffic manager it will perform a best effort canary by controlling the number of pods between stable and canary. At the time of this writing OpenShift Routes are not supported as a traffic manager but it is on the OpenShift GitOps team roadmap.

Finally check Argo CD and note that the status of the Application is suspended since the Argo rollouts are in a Paused state.

![alt text](https://raw.githubusercontent.com/gitops-examples/rollouts-demo/main/docs/img/argo-suspended.png)

At this point you can proceed to promote both deployments and watch them go to completion, this is done by clicking the `Promote` button in the Argo Rollouts UI or selecting the `Promote` menu action in the OpenShift console plugin.

### Testing Rollbacks

If you want to test performing a rollback, first go into Argo CD and disable automatic sync for the `rollouts-demo-prod` application, if you do not do this Argo CD will automatically revert the rollback back to the state in git, which is expected, but prevents the rollback.

Once the automatic sync is disabled you can then perform a rollback to the previous blue version. Note that like Deployment rollbacks are essentially a roll forward with the previous versions image.
