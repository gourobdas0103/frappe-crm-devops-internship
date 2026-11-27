# =============================================================================
# AWS Provider Configuration
# =============================================================================

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile != "" ? var.aws_profile : null

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      CostCenter  = var.cost_center
      Owner       = var.owner
      ManagedBy   = "Terraform"
      Repository  = "frappe-crm-devops-internship"
    }
  }
}
