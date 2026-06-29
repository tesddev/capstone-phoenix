# gitops — Argo CD Application

Apply this once after Argo CD is installed and the out-of-band `taskapp-secret` exists:

```bash
kubectl apply -f gitops/taskapp-application.yaml
```

Then check:

```bash
kubectl -n argocd get applications.argoproj.io
argocd app get taskapp
```

For the demo, change `manifests/taskapp/06-frontend.yaml` replicas from 2 to 3, commit, push, and show Argo CD syncing without manual `kubectl apply`.
