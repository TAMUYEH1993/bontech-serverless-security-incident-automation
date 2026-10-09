# Terraform Phase 1 — CLI, AWS Provider & AWS CLI Setup

## Objective

This document records the **exact commands used during the initial Terraform setup**, what each command means, why it was used, and the contents of the first Terraform file (`provider.tf`).

> **Security:** No real AWS Access Key ID, Secret Access Key, account ID, or session credential is stored in this repository.

---

## Command 1 — Check the Terraform installation

```powershell
terraform --version
```

**Meaning:** Asks the Terraform CLI to display its installed version and operating-system architecture.

**Why we used it:** To confirm Terraform was installed correctly and PowerShell could find the `terraform` executable.

Validated environment:

```text
Terraform v1.11.0
on windows_amd64
```

---

## Command 2 — Move to the Documents directory

```powershell
cd $HOME\Documents
```

**Meaning:**
- `cd` = Change Directory.
- `$HOME` represents the current Windows user's home directory.

**Why we used it:** We did not want to build the Terraform project inside `C:\Windows\System32`. The Documents directory provides a dedicated user workspace.

---

## Command 3 — Create the Terraform project directory

```powershell
mkdir BonTech-Serverless-Terraform
```

**Meaning:** `mkdir` means **Make Directory**.

**Why we used it:** Creates a dedicated directory for the Terraform configuration associated with the BonTech serverless security project.

---

## Command 4 — Enter the Terraform project directory

```powershell
cd BonTech-Serverless-Terraform
```

**Meaning:** Changes the current working directory into the new Terraform project folder.

**Why we used it:** Terraform operates on the `.tf` configuration files in the current working directory.

---

## Command 5 — Confirm the current working directory

```powershell
pwd
```

**Meaning:** `pwd` = **Print Working Directory**. It does **not** mean password.

**Why we used it:** Confirms that PowerShell is operating inside the intended Terraform project directory before files are created.

---

## Command 6 — Create/open the AWS provider configuration

```powershell
notepad provider.tf
```

**Meaning:** Opens a file named `provider.tf` in Windows Notepad. If it does not exist, Notepad allows it to be created.

**Why we used it:** `provider.tf` defines which Terraform provider the project requires and which AWS Region it will manage.

### Contents added to provider.tf

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

### What the configuration means

```hcl
terraform {
  required_providers {
```

Tells Terraform that the configuration has external provider requirements.

```hcl
aws = {
  source = "hashicorp/aws"
}
```

Tells Terraform to use the official HashiCorp AWS provider.

```hcl
version = "~> 6.0"
```

Constrains the project to a compatible AWS Provider 6.x release rather than silently moving to an incompatible future major version.

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Configures AWS as the provider and sets **US East (N. Virginia)** as the target Region.

**Important:** AWS access keys and secret keys are deliberately **not** written into `provider.tf`.

---

## Command 7 — Verify the contents of provider.tf

```powershell
Get-Content provider.tf
```

**Meaning:** PowerShell `Get-Content` reads and displays the contents of a text file.

**Why we used it:** To verify that `provider.tf` was actually saved and contained the expected Terraform configuration before initialization.

---

## Command 8 — Initialize the Terraform working directory

```powershell
terraform init
```

**Meaning:** Initializes the current Terraform directory.

**What it does:**
- Reads the Terraform configuration.
- Determines which providers are required.
- Downloads/installs the AWS provider.
- Initializes Terraform's working files.
- Creates/updates the dependency lock file.

**Important:** `terraform init` does **not** create the project's AWS resources.

During this lab, Terraform selected and installed the HashiCorp AWS provider and created:

```text
.terraform/
.terraform.lock.hcl
```

---

# Troubleshooting the Terraform Registry Connection

The first `terraform init` attempts could reach the Terraform Registry but the HTTPS connection was reset. The following commands were used to isolate the network problem.

## Command 9 — Test HTTPS/TCP connectivity to the Terraform Registry

```powershell
Test-NetConnection registry.terraform.io -Port 443
```

**Meaning:** Tests whether the workstation can establish a TCP connection to `registry.terraform.io` on port **443**.

**Why port 443?** HTTPS normally uses TCP port 443.

The test returned:

```text
TcpTestSucceeded : True
```

This showed that basic TCP connectivity to the Terraform Registry was available.

---

## Command 10 — Test the Terraform Registry specifically over IPv4

```powershell
curl.exe -4 https://registry.terraform.io/.well-known/terraform.json
```

**Meaning:**
- `curl.exe` performs an HTTP/HTTPS request.
- `-4` forces the request to use **IPv4**.
- The URL is Terraform Registry's discovery endpoint.

**Why we used it:** Earlier Terraform errors showed an IPv6 connection being reset. This command tested whether the same registry endpoint worked correctly using IPv4.

A successful response confirmed the registry was reachable over IPv4.

---

## Command 11 — Configure Windows to prefer IPv4 over IPv6

> This command was run from **PowerShell as Administrator** during troubleshooting.

```powershell
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name "DisabledComponents" -PropertyType DWord -Value 0x20 -Force
```

**Meaning:** Creates or updates the Windows `DisabledComponents` TCP/IP registry value.

**Why we used it:** In this specific workstation troubleshooting case, IPv4 access to the Terraform Registry worked while Terraform's IPv6 HTTPS connection was being reset. The value `0x20` tells Windows to prefer IPv4 over IPv6.

**Important:** This is a machine-level networking change, not a standard Terraform requirement. It should not be applied automatically to other computers merely because Terraform initialization fails. The underlying network problem should be diagnosed first.

A Windows restart was performed afterward so the networking preference could take effect.

---

## Command 12 — Return to the Terraform directory after restart

```powershell
cd $HOME\Documents\BonTech-Serverless-Terraform
```

**Meaning:** Returns PowerShell to the Terraform project directory.

---

## Command 13 — Retry Terraform initialization

```powershell
terraform init
```

**Result:** Terraform successfully initialized and installed the AWS provider.

The successful message was:

```text
Terraform has been successfully initialized!
```

That line is **output from Terraform**, not a command to type.

---

# AWS CLI Authentication Setup

After Terraform was initialized, AWS authentication was verified before allowing Terraform to manage any AWS resource.

## Command 14 — Ask AWS which identity is currently authenticated

```powershell
aws sts get-caller-identity
```

**Meaning:**
- `aws` = AWS Command Line Interface.
- `sts` = AWS **Security Token Service**.
- `get-caller-identity` asks AWS to identify the principal represented by the current credentials.

**Why we used it:** Before infrastructure changes, it is important to know **which AWS identity and account the workstation is authenticated to**.

The first attempt returned `InvalidClientTokenId`, showing that the locally stored credentials were no longer valid.

---

## Command 15 — Inspect where AWS CLI configuration is coming from

```powershell
aws configure list
```

**Meaning:** Displays the AWS CLI's active configuration sources, including profile, credential source, and Region.

**Why we used it:** It showed that AWS CLI was reading credentials from the local shared credentials file and using `us-east-1`.

The command masks credential values rather than printing the complete secret key.

---

## Command 16 — Configure AWS CLI credentials locally

```powershell
aws configure
```

**Meaning:** Starts the interactive AWS CLI configuration process.

It requests:

```text
AWS Access Key ID:
AWS Secret Access Key:
Default region name:
Default output format:
```

For this lab:

```text
Default region name: us-east-1
Default output format: json
```

**Security rule:** The actual Access Key ID and Secret Access Key are **not documented here, stored in Terraform files, or committed to GitHub**.

---

## Command 17 — Verify AWS communication again

```powershell
aws sts get-caller-identity
```

**Meaning:** Repeats the STS identity check using the newly configured local credentials.

A successful result contains fields similar to:

```json
{
  "UserId": "<REDACTED>",
  "Account": "<ACCOUNT-ID>",
  "Arn": "arn:aws:iam::<ACCOUNT-ID>:user/<IAM-USER>"
}
```

This confirms the communication path:

```text
Windows workstation
        ↓
AWS CLI
        ↓
Locally configured AWS credentials
        ↓
AWS Security Token Service (STS)
        ↓
Authenticated AWS IAM identity
        ↓
AWS account
```

---

# Security Lessons from the Setup

1. Do not hard-code AWS credentials in Terraform configuration.
2. Do not commit credentials to GitHub.
3. Do not publish screenshots containing secret access keys.
4. Verify the active identity with `aws sts get-caller-identity` before making AWS changes.
5. Rotate/revoke a credential immediately if it is accidentally exposed.
6. Troubleshoot connectivity methodically rather than repeatedly changing Terraform configuration.

---

# Command Sequence — Quick Reference

```powershell
terraform --version

cd $HOME\Documents
mkdir BonTech-Serverless-Terraform
cd BonTech-Serverless-Terraform
pwd

notepad provider.tf
Get-Content provider.tf

terraform init

Test-NetConnection registry.terraform.io -Port 443
curl.exe -4 https://registry.terraform.io/.well-known/terraform.json

# Administrator PowerShell — only for the diagnosed IPv6 issue on this workstation:
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name "DisabledComponents" -PropertyType DWord -Value 0x20 -Force

# After Windows restart:
cd $HOME\Documents\BonTech-Serverless-Terraform
terraform init

aws sts get-caller-identity
aws configure list
aws configure
aws sts get-caller-identity
```

## Terraform DynamoDB Deployment — Commands and Meanings

The first Terraform-managed AWS resource is now complete.

| Command | Meaning | Why it was used |
|---|---|---|
| `notepad main.tf` | Opens/creates the main Terraform configuration file. | Defined the DynamoDB resource as Infrastructure as Code. |
| `terraform fmt` | **Format** Terraform configuration into standard HCL formatting. | Keeps Terraform code consistent and readable. |
| `terraform validate` | Checks whether the Terraform configuration is syntactically and structurally valid. | Catches configuration errors before planning or applying. |
| `terraform plan` | Compares configuration, state, and real infrastructure and previews proposed changes. | Allowed review before AWS was changed. Initial result: **1 to add, 0 to change, 0 to destroy**. |
| `terraform apply` | Executes the approved Terraform plan against the configured provider. | Created the DynamoDB table in AWS. |
| `yes` | Explicit approval entered at Terraform's interactive apply checkpoint. | Authorized Terraform to perform the proposed change. |
| `terraform state list` | Lists resource addresses Terraform currently tracks in state. | Confirmed `aws_dynamodb_table.security_incidents` is managed by Terraform. |
| `terraform state show aws_dynamodb_table.security_incidents` | Displays the stored state details for that managed resource. | Confirmed the real table properties known to Terraform. |
| `notepad .gitignore` | Opens/creates Git ignore rules. | Added protections so local state, provider downloads, plan files, and potentially sensitive variable files are not committed. |
| `Get-Content .gitignore` | Displays the saved `.gitignore` file in PowerShell. | Verified the security exclusions were saved correctly. |
| `terraform plan` *(after apply)* | Refreshes and compares configuration/state/infrastructure again. | Returned **No changes. Your infrastructure matches the configuration**, proving the deployed resource and Terraform configuration are synchronized. |

### main.tf resource

```hcl
resource "aws_dynamodb_table" "security_incidents" {
  name         = "BonTech-Security-Incidents-Terraform"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "incident_id"

  attribute {
    name = "incident_id"
    type = "S"
  }

  tags = {
    ManagedBy = "Terraform"
    Project   = "BonTech-Serverless-Security"
  }
}
```

### What each DynamoDB setting means

- `resource "aws_dynamodb_table" "security_incidents"` — declares a DynamoDB table resource and gives Terraform the local resource address `aws_dynamodb_table.security_incidents`.
- `name` — the table name created in AWS.
- `billing_mode = "PAY_PER_REQUEST"` — uses DynamoDB on-demand capacity instead of manually provisioned read/write capacity.
- `hash_key = "incident_id"` — makes `incident_id` the table partition key.
- `type = "S"` — defines the key attribute as a string.
- `ManagedBy = "Terraform"` — identifies Terraform as the management method.
- `Project` — associates the resource with this serverless security project.

### Deployment result

Terraform reported:

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

AWS Console verification confirmed the table was **Active**, used `incident_id` as the String partition key, and used on-demand capacity.

The subsequent plan reported:

```text
No changes. Your infrastructure matches the configuration.
```

This demonstrates the core Terraform lifecycle:

```text
Write configuration
      ↓
terraform fmt
      ↓
terraform validate
      ↓
terraform plan
      ↓
Review proposed changes
      ↓
terraform apply
      ↓
AWS resource created
      ↓
Terraform state tracks resource
      ↓
terraform plan again
      ↓
No drift / no changes
```

## State and GitHub Security

Terraform state is intentionally excluded from version control because state can contain infrastructure metadata and potentially sensitive values.

The Terraform folder includes a `.gitignore` that excludes:

```text
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
*.tfvars
*.tfvars.json
crash.log
crash.*.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

The dependency lock file `.terraform.lock.hcl` should normally be committed when the local project is committed through Git so provider selections remain reproducible.

## Current Terraform Checkpoint

**Completed:** Terraform CLI setup → AWS provider initialization → AWS CLI authentication → DynamoDB configuration → formatting → validation → plan review → apply → AWS verification → Terraform state verification → Git safety controls → post-apply no-change plan.

**Next:** continue converting the remaining serverless security architecture to Terraform while preserving least privilege and validating each resource before apply.
