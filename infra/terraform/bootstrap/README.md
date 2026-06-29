# Terraform backend bootstrap

Run this once before the main Terraform stack. It creates:

- an encrypted, versioned S3 bucket for remote Terraform state
- a DynamoDB table for Terraform state locking

```bash
cd infra/terraform/bootstrap
terraform init
terraform apply
terraform output
```

Then copy the outputs into `../backend.hcl` using `../backend.hcl.example` as the template.
