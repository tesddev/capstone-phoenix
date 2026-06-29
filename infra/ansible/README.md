# infra/ansible — k3s cluster bring-up

## Generate inventory from Terraform outputs

From `infra/terraform`:

```bash
terraform output -json > ../ansible/terraform-output.json
cd ../ansible
python3 scripts/render_inventory.py terraform-output.json > inventory.ini
```

## Install Ansible collections

```bash
ansible-galaxy collection install -r requirements.yml
```

## Confirm SSH works

```bash
ansible all -i inventory.ini -m ping
```

## Build the cluster

```bash
ansible-playbook -i inventory.ini site.yml
export KUBECONFIG=$PWD/kubeconfig
kubectl get nodes -o wide
```

Run the playbook twice and save the second run output as idempotency evidence.
