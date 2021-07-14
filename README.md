# smi-demo
Service Mesh Interface CI/CD demo for Cap


## Setup AKS cluster

```bash
az ad sp create-for-rbac -n smi-sp-juda --skip-assignment                                   

Changing "smi-sp-juda" to a valid URI of "http://smi-sp-juda", which is the required format used for service principal names
AppId                                 DisplayName    Name                Password                              Tenant
------------------------------------  -------------  ------------------  ------------------------------------  ------------------------------------
1c3411d3-6825-455a-aea9-7fc806db5c98  smi-sp-juda    http://smi-sp-juda  4c62254e-{snip}-20d355687eeb  72f988bf-
{snip}-2d7cd011db47
```


```bash
az aks create -g cap -n cap --enable-vmss --network-plugin azure --service-principal 1c3411d3-{snip}-7fc806db5c98 --client-secret 4c62254e-{snip}-20d355687eeb
```

```bash
k create ns monitoring                                                                                    
namespace/monitoring created
```



## Install Linkerd
```bash
brew install linkerd
```

```bash
linkerd check --pre

kubernetes-api
--------------
√ can initialize the client
√ can query the Kubernetes API

kubernetes-version
------------------
√ is running the minimum Kubernetes API version
√ is running the minimum kubectl version

pre-kubernetes-setup
--------------------
√ control plane namespace does not already exist
√ can create non-namespaced resources
√ can create ServiceAccounts
√ can create Services
√ can create Deployments
√ can create CronJobs
√ can create ConfigMaps
√ can create Secrets
√ can read Secrets
√ can read extension-apiserver-authentication configmap
√ no clock skew detected

pre-kubernetes-capability
-------------------------
√ has NET_ADMIN capability
√ has NET_RAW capability

linkerd-version
---------------
√ can determine the latest version
√ cli is up-to-date

Status check results are √
```


### Deploy Linkerd control plane
```bash
linkerd install | kubectl apply -f -

namespace/linkerd created
clusterrole.rbac.authorization.k8s.io/linkerd-linkerd-identity created
clusterrolebinding.rbac.authorization.k8s.io/linkerd-linkerd-identity created
serviceaccount/linkerd-identity created
clusterrole.rbac.authorization.k8s.io/linkerd-linkerd-controller created
clusterrolebinding.rbac.authorization.k8s.io/linkerd-linkerd-controller created
serviceaccount/linkerd-controller created
clusterrole.rbac.authorization.k8s.io/linkerd-linkerd-destination created
clusterrolebinding.rbac.authorization.k8s.io/linkerd-linkerd-destination created
serviceaccount/linkerd-destination created
role.rbac.authorization.k8s.io/linkerd-heartbeat created
rolebinding.rbac.authorization.k8s.io/linkerd-heartbeat created
serviceaccount/linkerd-heartbeat created
role.rbac.authorization.k8s.io/linkerd-web created
rolebinding.rbac.authorization.k8s.io/linkerd-web created
clusterrole.rbac.authorization.k8s.io/linkerd-linkerd-web-check created
clusterrolebinding.rbac.authorization.k8s.io/linkerd-linkerd-web-check created
clusterrolebinding.rbac.authorization.k8s.io/linkerd-linkerd-web-admin created
serviceaccount/linkerd-web created
customresourcedefinition.apiextensions.k8s.io/serviceprofiles.linkerd.io created
customresourcedefinition.apiextensions.k8s.io/trafficsplits.split.smi-spec.io created
clusterrole.rbac.authorization.k8s.io/linkerd-linkerd-prometheus created
clusterrolebinding.rbac.authorization.k8s.io/linkerd-linkerd-prometheus created
serviceaccount/linkerd-prometheus created
clusterrole.rbac.authorization.k8s.io/linkerd-linkerd-proxy-injector created
clusterrolebinding.rbac.authorization.k8s.io/linkerd-linkerd-proxy-injector created
serviceaccount/linkerd-proxy-injector created
secret/linkerd-proxy-injector-tls created
mutatingwebhookconfiguration.admissionregistration.k8s.io/linkerd-proxy-injector-webhook-config created
clusterrole.rbac.authorization.k8s.io/linkerd-linkerd-sp-validator created
clusterrolebinding.rbac.authorization.k8s.io/linkerd-linkerd-sp-validator created
serviceaccount/linkerd-sp-validator created
secret/linkerd-sp-validator-tls created
validatingwebhookconfiguration.admissionregistration.k8s.io/linkerd-sp-validator-webhook-config created
clusterrole.rbac.authorization.k8s.io/linkerd-linkerd-tap created
clusterrole.rbac.authorization.k8s.io/linkerd-linkerd-tap-admin created
clusterrolebinding.rbac.authorization.k8s.io/linkerd-linkerd-tap created
clusterrolebinding.rbac.authorization.k8s.io/linkerd-linkerd-tap-auth-delegator created
serviceaccount/linkerd-tap created
rolebinding.rbac.authorization.k8s.io/linkerd-linkerd-tap-auth-reader created
secret/linkerd-tap-tls created
apiservice.apiregistration.k8s.io/v1alpha1.tap.linkerd.io created
podsecuritypolicy.policy/linkerd-linkerd-control-plane created
role.rbac.authorization.k8s.io/linkerd-psp created
rolebinding.rbac.authorization.k8s.io/linkerd-psp created
configmap/linkerd-config created
secret/linkerd-identity-issuer created
service/linkerd-identity created
deployment.apps/linkerd-identity created
service/linkerd-controller-api created
deployment.apps/linkerd-controller created
service/linkerd-dst created
deployment.apps/linkerd-destination created
cronjob.batch/linkerd-heartbeat created
service/linkerd-web created
deployment.apps/linkerd-web created
configmap/linkerd-prometheus-config created
service/linkerd-prometheus created
deployment.apps/linkerd-prometheus created
deployment.apps/linkerd-proxy-injector created
service/linkerd-proxy-injector created
service/linkerd-sp-validator created
deployment.apps/linkerd-sp-validator created
service/linkerd-tap created
deployment.apps/linkerd-tap created
configmap/linkerd-config-addons created
serviceaccount/linkerd-grafana created
configmap/linkerd-grafana-config created
service/linkerd-grafana created
deployment.apps/linkerd-grafana created
```

## Blind


## Readiness and Health


## Canary

Install Flagger

```bash
kubectl apply -k github.com/fluxcd/flagger/kustomize/linkerd
```

### Create Canary Namespace
```bash
kubectl create ns canary
```

```bash
kubectl apply -f canary/flagger.yml
```

### Test

```bash
kubectl -n canary port-forward svc/podinfo 9898
open http://localhost:9898 
```

### Deploy Canary configuration

```bash
kubectl apply -f canary/canary.flagger.yaml
```

```bash
kubectl -n canary get svc
NAME              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
frontend          ClusterIP   10.0.213.163   <none>        8080/TCP   13m
podinfo           ClusterIP   10.0.136.37    <none>        9898/TCP   13m
podinfo-canary    ClusterIP   10.0.84.161    <none>        9898/TCP   8m31s
podinfo-primary   ClusterIP   10.0.46.86     <none>        9898/TCP   8m31s
```

### Initialte canary release

```bash
kubectl -n canary set image deployment/podinfo podinfod=quay.io/stefanprodan/podinfo:1.7.1

```

```bash
watch kubectl -n canary get canary
```

or

```bash
linkerd dashboard
open http://localhost:50750/namespaces/canary/trafficsplits/podinfo
```

#### View in Browser

```bash
kubectl -n canary port-forward svc/frontend 8080
open http://localhost:8080/
```
