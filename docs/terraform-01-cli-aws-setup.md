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

## Current Terraform Checkpoint

**Completed:**

```text
Terraform installation
        ↓
Dedicated project directory
        ↓
provider.tf
        ↓
AWS provider definition
        ↓
terraform init
        ↓
AWS provider installed
        ↓
AWS CLI credential configuration
        ↓
STS identity verification
        ↓
AWS communication established
```

No Terraform-managed AWS infrastructure has been applied at this checkpoint.

**Next:** define the first AWS resource, then run `terraform fmt`, `terraform validate`, and `terraform plan` before any `terraform apply`.
