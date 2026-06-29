# Runbook — Capstone Phoenix

This rebuilds the project from a fresh AWS account and empty Kubernetes cluster.

## 0. Local setup

```bash
brew install awscli terraform ansible kubectl helm jq
aws configure set region eu-west-1
aws sts get-caller-identity
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/capstone-phoenix -C "capstone-phoenix" -N ""
```

## 1. Clone repo

```bash
git clone https://github.com/tesddev/capstone-phoenix.git
cd capstone-phoenix
```

## 2. Provision Terraform remote state

```bash
cd infra/terraform/bootstrap
terraform init
terraform apply
terraform output
```

Create the main backend file:

```bash
cd ..
cp backend.hcl.example backend.hcl
```

Edit `backend.hcl` with the bootstrap outputs.

## 3. Provision AWS infrastructure

```bash
cp terraform.tfvars.example terraform.tfvars
curl -s https://checkip.amazonaws.com
```

Edit `terraform.tfvars` and set `admin_cidr` to your IP with `/32`.

```bash
terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform output -json > ../ansible/terraform-output.json
```

## 4. Build the k3s cluster with Ansible

```bash
cd ../ansible
python3 scripts/render_inventory.py terraform-output.json > inventory.ini
ansible-galaxy collection install -r requirements.yml
ansible all -i inventory.ini -m ping
ansible-playbook -i inventory.ini site.yml
export KUBECONFIG=$PWD/kubeconfig
kubectl get nodes -o wide
```

Run Ansible a second time and save the output as idempotency evidence.

## 5. Update DuckDNS

Point `taskapp-tesleem.duckdns.org` to the public IP you want to use:

```bash
cd ../terraform
terraform output control_plane_public_ip
```

Update the A record in DuckDNS.

## 6. Install platform components

From repo root:

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

## 7. Create app Secret out-of-band

```bash
export DATABASE_PASSWORD="$(openssl rand -base64 24)"
export SECRET_KEY="$(openssl rand -hex 32)"
./scripts/create-taskapp-secret.sh
```

## 8. Let Argo CD deploy the app

```bash
kubectl apply -f gitops/taskapp-application.yaml
kubectl -n argocd get applications.argoproj.io
kubectl get pods -n taskapp -o wide
kubectl get ingress -n taskapp
```

## 9. Verify TLS

```bash
curl -vI https://taskapp-tesleem.duckdns.org
curl -s https://taskapp-tesleem.duckdns.org/api/health
```

## 10. Day-2 operations

### Scale frontend through GitOps

Edit `manifests/taskapp/06-frontend.yaml`:

```yaml
replicas: 3
```

Then:

```bash
git add manifests/taskapp/06-frontend.yaml
git commit -m "Scale frontend to 3 replicas"
git push
kubectl get pods -n taskapp -w
```

Argo CD should sync the change automatically.

### Roll back a bad deploy

```bash
git revert <bad-commit-sha>
git push
kubectl rollout status deployment/backend -n taskapp
```

### Worker node failure demo

```bash
kubectl get pods -n taskapp -o wide
kubectl drain <worker-node-name> --ignore-daemonsets --delete-emptydir-data
kubectl get pods -n taskapp -o wide -w
curl -I https://taskapp-tesleem.duckdns.org
```

Restore the node:

```bash
kubectl uncordon <worker-node-name>
```

### Postgres persistence test

```bash
kubectl delete pod postgres-0 -n taskapp
kubectl get pod postgres-0 -n taskapp -w
```

Then verify the app still has its data.

### HPA test

```bash
kubectl get hpa -n taskapp -w
kubectl run load-test --rm -it --image=busybox:1.36 --restart=Never -- /bin/sh
while true; do wget -q -O- http://backend.taskapp.svc.cluster.local:5000/api/health; done
```

## 11. Destroy when done

```bash
cd infra/terraform
terraform destroy
```

Then optionally destroy the backend resources:

```bash
cd bootstrap
terraform destroy
```
