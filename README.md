# Azure POC: Terraform Landing Zone

Terraform code that builds an Azure landing zone under the `AzurePoc` management group, deployed through a GitHub Actions pipeline.

## Structure
- `.github/workflows/`: GitHub Actions pipeline (plan on push, apply behind an approval gate)
- `*.tf`: Terraform configuration for management groups, subscriptions, and resources

## Series
This code accompanies a LinkedIn build-in-public series on rebuilding an Azure landing zone in Terraform.