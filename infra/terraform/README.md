# infra/terraform — AWS infrastructure

This stack provisions:

- one VPC and public subnet
- one k3s control-plane EC2 instance
- two k3s worker EC2 instances
- one least-privilege security group
- outputs consumed by Ansible

## 1. Bootstrap remote state

```bash
cd infra/terraform/bootstrap
terraform init
terraform apply
terraform output
```

Create `infra/terraform/backend.hcl` from `backend.hcl.example` and paste the bootstrap outputs.

## 2. Configure variables

```bash
cd ..
cp terraform.tfvars.example terraform.tfvars
curl -s https://checkip.amazonaws.com
```

Edit `terraform.tfvars` and replace `REPLACE_WITH_YOUR_IP/32` with your IP, for example `1.2.3.4/32`.

## 3. Provision

```bash
terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform output -json > ../ansible/terraform-output.json
```

## Security note

Port `6443` is only allowed from your `admin_cidr`, never from `0.0.0.0/0`.
