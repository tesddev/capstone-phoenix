# platform — cluster add-ons

Run this after Ansible creates the k3s cluster.

```bash
export KUBECONFIG=$PWD/infra/ansible/kubeconfig

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --values platform/ingress-nginx/values.yaml

kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set crds.enabled=true
kubectl apply -f platform/cert-manager/clusterissuers.yaml

kubectl create namespace metrics-server --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace metrics-server \
  --values platform/metrics-server/values.yaml

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --values platform/argocd/values.yaml
```

Argo CD UI access, if needed:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d && echo
```
