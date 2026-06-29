# Cost

Region: `eu-west-1`

These are planning estimates. Confirm exact live pricing with the AWS Pricing Calculator before final submission.

## Monthly itemized cost

| Item | Spec | Qty | Approx monthly cost |
|---|---|---:|---:|
| control-plane EC2 | `t3.micro`, Linux | 1 | Free-tier eligible if covered, otherwise low single digits USD |
| worker EC2 | `t3.micro`, Linux | 2 | partly free-tier eligible depending account usage; otherwise low double digits USD total |
| EBS root volumes | gp3, 20 GiB each | 3 | low single digits USD |
| Postgres PVC | local-path on node disk | 1 | included in node EBS usage |
| S3 Terraform state | small encrypted bucket | 1 | cents |
| DynamoDB lock table | on-demand, tiny usage | 1 | cents |
| DuckDNS | free subdomain | 1 | $0 |
| Load balancer | none; ingress-nginx uses hostNetwork | 0 | $0 |
| **Total** | | | roughly low tens USD/month outside free-tier |

## Compared to single-server Compose + Portainer

The single-server version is cheaper and simpler because it runs everything on one VM. This Kubernetes cluster costs more because it needs three separate nodes, persistent storage, ingress, cert-manager, metrics, and Argo CD. The extra spend buys multi-node scheduling, self-healing, rolling updates, HPA, network isolation, and a GitOps deployment flow.

## How I would halve this

For a real low-cost production-style setup, I would keep one small control-plane, use smaller/spot worker instances, stop the cluster outside demo hours, and move Postgres to a managed free-tier database only if the managed database is cheaper than keeping extra disk and memory on the worker. For this capstone, I kept three nodes because the rubric requires a real multi-node cluster and live failover evidence.
