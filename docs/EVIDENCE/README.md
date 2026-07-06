# EVIDENCE

Add screenshots/logs here with these exact names:

- `nodes-ready.png` — `kubectl get nodes -o wide`
- `pods-spread.png` — `kubectl get pods -n taskapp -o wide`
- `tls-valid.png` — `curl -vI https://taskapp-tesleem.duckdns.org`
- `website-up.png` — screenshot showing TaskApp served successfully before cost shutdown
- `pvc-persist.log` — proof data survives `kubectl delete pod postgres-0 -n taskapp`
- `zero-downtime.log` — unbroken 200s during a rollout
- `hpa-scale.png` — HPA replicas increasing under load
- `argocd-synced.png` — Argo CD Synced + Healthy
- `failover.png` — app remains available after worker drain
- `ansible-idempotent.log` — second Ansible run shows no changes
- `terraform-plan-clean.log` — `terraform plan` after apply shows no changes
