# Terraform Phase — Initial CLI and AWS Provider Setup

## Objective

Begin converting the completed serverless security incident automation project into Infrastructure as Code (IaC) with Terraform.

This stage establishes the local Terraform workspace, initializes the HashiCorp AWS provider, and verifies that the local AWS CLI can authenticate to AWS before any infrastructure is created or changed.

## 1. Verify Terraform CLI

Terraform was verified from Windows PowerShell:

```powershell
terraform --version
```

Environment validated:

- Terraform CLI installed on Windows (amd64)
- Terraform version: 1.11.0

## 2. Create the Terraform workspace

A dedicated local working directory was created:

```powershell
cd $HOME\Documents
mkdir BonTech-Serverless-Terraform
cd BonTech-Serverless-Terraform
pwd
```

The workspace keeps Terraform configuration separate from operating-system directories.

## 3. Configure the AWS provider

Created `provider.tf`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

No AWS access key or secret key is stored in Terraform source code.

## 4. Initialize Terraform

Terraform initialization initially failed while contacting `registry.terraform.io`. Troubleshooting confirmed HTTPS connectivity and isolated the failure to the IPv6 path, while an IPv4 request to the Terraform Registry succeeded.

After correcting the local networking preference and restarting Windows, initialization completed:

```powershell
terraform init
```

Terraform successfully installed the HashiCorp AWS provider and generated the dependency lock file:

```text
.terraform.lock.hcl
```

## 5. Verify AWS CLI authentication

Before allowing Terraform to interact with AWS resources, AWS CLI identity was tested:

```powershell
aws sts get-caller-identity
```

An old local credential was rejected, so the credential source was inspected:

```powershell
aws configure list
```

A new lab CLI credential was configured locally with `aws configure`. Credentials are intentionally excluded from this repository.

The final STS identity check succeeded, confirming:

```text
Local workstation
      ↓
AWS CLI credentials
      ↓
AWS Security Token Service (STS)
      ↓
Authenticated IAM identity
      ↓
AWS account
```

## Security Notes

- Never commit AWS access keys or secret access keys.
- Never place long-term credentials directly in `provider.tf`.
- Screenshots containing credentials must not be published.
- `aws sts get-caller-identity` is used to verify the active AWS identity before infrastructure changes.
- Any credential accidentally exposed during testing should be revoked/rotated before further use.

## Current Checkpoint

At this checkpoint:

- Terraform CLI installed and verified — complete
- Dedicated Terraform workspace — complete
- AWS provider configuration — complete
- `terraform init` — complete
- AWS provider downloaded — complete
- AWS CLI authentication path — verified
- Terraform-managed AWS resources — **not created yet**
- `terraform apply` — **not run yet**

The next stage is to define the first AWS resource in Terraform, validate the configuration, and review a `terraform plan` before making any AWS infrastructure changes.
