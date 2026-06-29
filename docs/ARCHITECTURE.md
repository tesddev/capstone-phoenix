# Architecture — Capstone Phoenix

## 1. Topology diagram

```text
Internet
  │
  │  HTTPS:443 / HTTP:80
  ▼
DuckDNS: taskapp-tesleem.duckdns.org
  │
  ▼
AWS Security Group
  ├─ 80/443 from world
  ├─ 22 from admin_cidr only
  └─ 6443 from admin_cidr only, never 0.0.0.0/0
  │
  ▼
k3s cluster on AWS eu-west-1
  ├─ cp-1: k3s server / control-plane
  ├─ worker-1: k3s agent
  └─ worker-2: k3s agent
        │
        ▼
ingress-nginx DaemonSet, hostNetwork 80/443
        │
        ├─ /       → frontend Service:80 → frontend Pods x2
        └─ /api    → backend Service:5000 → backend Pods x2
                                           │
                                           ▼
                                  postgres Service:5432
                                           │
                                           ▼
                                  postgres StatefulSet + PVC
```

## 2. Node and network

- Cloud: AWS
- Region: `eu-west-1`
- Nodes: 1 k3s server and 2 k3s workers
- Instance type: `t3.micro` for cost control
- VPC CIDR: `10.42.0.0/16`
- Public subnet: `10.42.1.0/24`
- Security group:
  - `80` and `443` open globally for public web traffic and Let's Encrypt HTTP-01
  - `22` restricted to `admin_cidr`
  - `6443` restricted to `admin_cidr`, not public
  - all node-to-node traffic allowed only between instances in the same security group

## 3. Request flow

A user opens `https://taskapp-tesleem.duckdns.org`. DuckDNS resolves the name to the public IP of one cluster node. The AWS security group allows the request on port `443`. `ingress-nginx` receives the request on the node using `hostNetwork`, terminates TLS using a cert-manager/Let's Encrypt certificate, and routes `/` to the frontend Service and `/api` to the backend Service. The backend connects to Postgres through the internal `postgres` Service on port `5432`.

## 4. Single-server assumptions fixed

| Single-server assumption | Why it breaks on Kubernetes | Fix used here |
|---|---|---|
| Run migrations in each backend container on boot | Multiple replicas can race on `alembic upgrade head` | Dedicated Kubernetes Job runs migration before backend rollout |
| Use a local Docker volume for Postgres | Pods can be killed/rescheduled | Postgres StatefulSet with PVC |
| Publish ports directly on one host | Multiple Pods across multiple nodes need one front door | ingress-nginx + Kubernetes Services |
| Manual deployment is acceptable | Final state must be reproducible and reconciled | Argo CD pulls from GitHub and self-heals |
| One container failure is manual recovery | Pods should self-heal | Deployments, probes, and ReplicaSets |
| Restart deploys can drop traffic | Rolling updates need to keep capacity online | `maxUnavailable: 0`, readiness probes, PDBs |
| Plain `.env` on server | Secrets must not be committed | Out-of-band Kubernetes Secret |

## 5. Choices and trade-offs

- **k3s instead of EKS:** cheaper and closer to the assessment goal of provisioning the cluster ourselves.
- **ingress-nginx instead of bundled Traefik:** Helm-based, common in industry, easy to demonstrate with cert-manager.
- **DuckDNS:** free domain option that still supports real Let's Encrypt certificates.
- **Same-origin `/api`:** avoids CORS complexity and needs only one certificate.
- **Out-of-band Secret:** fastest safe approach. Secret is created with `kubectl create secret` and not committed to Git.
- **NetworkPolicy:** k3s network policy enforcement is used. Policies default-deny the namespace and allow only the needed paths.
