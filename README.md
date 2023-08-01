Note WIP

### Introduction

This is a demonstration of Argo Rollouts integrated with Argo CD in a standard OpenShift without a Service Mesh installed. The demo
includes a pipeline that can be used to switch between images by using tags (blue, green, yellow, etc) and the pipeline will
update the image references in the development and production namespaces.

In development a normal Deployment is used, in Production both a bluegreen and canary rollout for the same application is deployed
so that both strategies supported by Rolouts can be shown.

### Installing the Demo

1. Fork this repo into your own space, this is required since the pipeline will update the repo with the new image references

2. Create a secret for github as follows:
