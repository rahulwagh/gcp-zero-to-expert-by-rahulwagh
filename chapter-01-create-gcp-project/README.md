# Chapter 1: Creating a Google Cloud Project with Terraform

## Overview

In this chapter, you'll learn how to create a Google Cloud Platform (GCP) project using Terraform. This is the foundation for managing your GCP infrastructure as code.

## What You'll Learn

- How to configure the Google Cloud provider in Terraform
- Creating a GCP project programmatically
- Using random suffixes to avoid GCP's 30-day project ID restriction
- Enabling required APIs for your project
- Managing project metadata and labels
- Using Terraform variables and outputs

## Prerequisites

Before you begin, ensure you have:

1. **Google Cloud Account**: Active GCP account with billing enabled
2. **Terraform**: Terraform installed (version >= 1.0)
   ```bash
   terraform --version
   ```
3. **Google Cloud SDK**: gcloud CLI installed and configured
   ```bash
   gcloud --version
   ```
4. **Authentication**: Set up authentication using one of these methods:
   - Application Default Credentials (ADC)
   - Service Account Key
   - User Account via gcloud

## Authentication Setup

### Option 1: Application Default Credentials (Recommended)

```bash
gcloud auth application-default login
```

### Option 2: Service Account Key

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-key.json"
```

## Required Permissions

Your account or service account needs these permissions:

- `resourcemanager.projects.create`
- `billing.accounts.get`
- `serviceusage.services.enable`

## Configuration Files

This chapter includes the following Terraform files:

- **provider.tf**: Configures the Google Cloud provider and Terraform version
- **main.tf**: Defines the project resource and API enablement
- **variables.tf**: Declares input variables
- **outputs.tf**: Defines output values after project creation
- **terraform.tfvars**: Configuration file with your GCP account values

## Setup Instructions

### Step 1: Configure Variables

Open `terraform.tfvars` and update the following values with your GCP account details:

```hcl
billing_account = "YOUR-BILLING-ACCOUNT-ID"  # Required
org_id          = ""                         # Leave empty for personal accounts
```

**Important**: For most personal/individual GCP accounts, leave `org_id` as an empty string `""`. Only set it if you're working under a GCP Organization.

To find your billing account ID:

```bash
gcloud billing accounts list
```

To find your organization ID (only if you have one):

```bash
gcloud organizations list
```

If the above command returns empty, you don't have an organization - keep `org_id = ""` in your terraform.tfvars.

### Step 2: Initialize Terraform

Initialize the Terraform working directory:

```bash
terraform init
```

This downloads the Google Cloud and Random provider plugins.

### Step 3: Plan the Deployment

Preview the changes Terraform will make:

```bash
terraform plan
```

Review the output to ensure it matches your expectations.

### Step 4: Apply the Configuration

Create the GCP project:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### Step 5: Verify the Project

Check that your project was created. Note that the actual project ID will have a 4-character random suffix:

```bash
# List all projects (look for cl-demo-sandboxterraform-XXXX)
gcloud projects list

# Or filter by prefix
gcloud projects list --filter="projectId:cl-demo-sandboxterraform*"

# Or get the project ID from Terraform output
terraform output project_id
```

## Understanding the Code

### Random Suffix for Project ID

To avoid GCP's 30-day soft delete restriction, we use a random suffix:

```hcl
resource "random_id" "project_suffix" {
  byte_length = 2  # 2 bytes = 4 hex characters
}
```

This generates a unique 4-character hex suffix (e.g., `a3f2`) that gets appended to your project ID. This allows you to:
- Destroy and recreate projects immediately for testing
- Avoid conflicts with recently deleted project IDs
- Each `terraform apply` creates a project with a unique ID like `cl-demo-sandboxterraform-a3f2`

### Project Resource

The `google_project` resource creates a new GCP project:

```hcl
resource "google_project" "demo_project" {
  name            = var.project_name
  project_id      = "${var.project_id}-${random_id.project_suffix.hex}"
  org_id          = var.org_id != "" ? var.org_id : null
  billing_account = var.billing_account

  labels = {
    environment = "demo"
    purpose     = "learning"
    course      = "gcp-zero-to-expert"
  }
}
```

**Notes**:
- The `project_id` includes the random suffix to ensure uniqueness
- The `org_id` uses a conditional expression - it's only set if provided, otherwise it's null

### API Enablement

The `google_project_service` resource enables required APIs:

```hcl
resource "google_project_service" "project_services" {
  for_each = toset(var.enabled_apis)

  project = google_project.demo_project.project_id
  service = each.value
}
```

## Outputs

After applying, Terraform will output:

- **project_id**: The unique project identifier (includes the 4-character random suffix, e.g., `cl-demo-sandboxterraform-a3f2`)
- **project_number**: The numeric project number
- **project_name**: The display name of the project
- **enabled_apis**: List of enabled APIs

You can view these outputs anytime by running:
```bash
terraform output
```

## Cleanup

To destroy the resources created in this chapter:

```bash
terraform destroy
```

**Notes**:
- This will delete the project. Ensure you don't have any important resources in it.
- Thanks to the random suffix, you can immediately run `terraform apply` again to create a new project without waiting 30 days.
- Each new apply will generate a different random suffix, creating a unique project ID.

## Common Issues

### Issue: "Error 404: Permission denied" or "resourcemanager.projectCreator permission"

**Error Message**:
```
Error: error creating project cl-demo-sandboxterraform (cl-demo-sandboxterraform):
googleapi: Error 404: Permission denied on resource or it may not exist., notFound.
If you received a 403 error, make sure you have the `roles/resourcemanager.projectCreator` permission
```

**Solutions**:

1. **Set `org_id` to empty string** (most common for personal accounts):
   ```hcl
   org_id = ""
   ```
   If you're using a personal GCP account without an organization, ensure `org_id` is set to an empty string in `terraform.tfvars`.

2. **Verify organization ID** (if using an organization):
   ```bash
   gcloud organizations list
   ```
   If you have an organization, use the actual org ID from this command.

3. **Check permissions**:
   - For personal accounts: Ensure billing is enabled
   - For organization accounts: Request `roles/resourcemanager.projectCreator` role from your organization admin

### Issue: "Project ID already exists"

**Solution**: Project IDs must be globally unique. Change the `project_id` in your `terraform.tfvars` file.

### Issue: "Billing account not found"

**Solution**: Verify your billing account ID:

```bash
gcloud billing accounts list
```

### Issue: "Permission denied"

**Solution**: Ensure your account has the required permissions listed above.

## Best Practices

1. **Unique Project IDs**: Always use unique, descriptive project IDs
2. **Labels**: Use labels to organize and track resources
3. **API Management**: Only enable APIs you actually need
4. **Version Control**: For learning purposes, `terraform.tfvars` is included. In production, consider excluding sensitive values
5. **State Management**: Consider using remote state (covered in later chapters)
6. **Organization ID**: Leave `org_id` empty for personal accounts to avoid permission errors

## Next Steps

In the next chapter, we'll explore:
- Setting up networking (VPC, Subnets)
- Creating compute resources
- Implementing security best practices

## Additional Resources

- [Terraform Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Project Documentation](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## Questions?

If you encounter any issues or have questions about this chapter, please:
- Check the Common Issues section above
- Review the Terraform and GCP documentation
- Open an issue in the course repository
