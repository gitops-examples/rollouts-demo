ROLLOUTS_DEMO_NS=rollouts-demo-gitops

echo "Fetching cluster subdomain"
export SUB_DOMAIN=$(oc get ingress.config.openshift.io cluster -n openshift-ingress -o jsonpath='{.spec.domain}')
echo "SUB_DOMAIN=${SUB_DOMAIN}"

echo "Create rollouts GitOps instance"
# echo "Create default instance of gitops operator"
kustomize build environments/overlaps/gitops | envsubst '${SUB_DOMAIN}' | oc apply -f -

echo "Pause $SLEEP_SECONDS seconds for the creation of the gitops-operator..."
sleep $SLEEP_SECONDS

echo "Waiting for deployments to start"
until oc get deployment cluster -n $ROLLOUTS_DEMO_NS
do
  sleep 5;
done

echo "Waiting for all pods to be created"
deployments=(cluster argocd-dex-server argocd-redis argocd-repo-server argocd-server)
for i in "${deployments[@]}";
do
  echo "Waiting for deployment $i";
  oc rollout status deployment $i -n $ROLLOUTS_DEMO_NS
done

echo "Install applications and pipelines"
kustomize build argocd/base --enable-helm | oc apply -f -