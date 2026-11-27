# =============================================================================
# Input Variables for Frappe CRM ECS Fargate Blue-Green Deployment
# =============================================================================

variable "aws_region" {
  description = "The selected AWS Region to deploy all infrastructure into"
  type        = string
  default     = "ap-south-1"
}

variable "aws_profile" {
  description = "Optional AWS CLI profile name for authentication"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Name of the project used for naming and tagging resources"
  type        = string
  default     = "frappe-crm"
}

variable "environment" {
  description = "Environment name (e.g. prod, staging, dev)"
  type        = string
  default     = "prod"
}

# --- Networking ---
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the 2 public subnets (ALB & NAT Gateway)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the 2 private subnets (ECS tasks, RDS, Redis)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# --- Compute / ECS Fargate ---
variable "fargate_cpu" {
  description = "Fargate task CPU units (1024 = 1 vCPU)"
  type        = number
  default     = 1024
}

variable "fargate_memory" {
  description = "Fargate task memory in MB (2048 = 2 GB)"
  type        = number
  default     = 2048
}

variable "app_count" {
  description = "Desired number of ECS Fargate task replicas"
  type        = number
  default     = 2
}

variable "container_port" {
  description = "Port exposed by the Frappe CRM container"
  type        = number
  default     = 8000
}

# --- Container Image & ECR ---
variable "ecr_repository_name" {
  description = "Name of the Amazon ECR repository"
  type        = string
  default     = "frappe-crm"
}

variable "image_tag" {
  description = "Container image tag to deploy"
  type        = string
  default     = "latest"
}

# --- Database (RDS MariaDB) ---
variable "db_instance_class" {
  description = "RDS DB instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "Name of the default MariaDB database"
  type        = string
  default     = "Admin"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "Admin"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
  default     = "AdminSecure2026!"
}

# --- Application Config ---
variable "admin_password" {
  description = "Frappe CRM Administrator user password"
  type        = string
  sensitive   = true
  default     = "Admin"
}

variable "site_name" {
  description = "Frappe site name"
  type        = string
  default     = "crm.localhost"
}

variable "enable_codedeploy" {
  description = "Enable AWS CodeDeploy application and deployment group (requires active account subscription)"
  type        = bool
  default     = false
}

# --- Blue-Green & Health Checks ---
variable "health_check_path" {
  description = "HTTP health check probe path for ALB target groups"
  type        = string
  default     = "/api/method/frappe.ping"
}

variable "deregistration_delay" {
  description = "Target group connection draining delay in seconds"
  type        = number
  default     = 30
}

variable "termination_wait_time_in_minutes" {
  description = "Time in minutes CodeDeploy waits before terminating original Blue task set"
  type        = number
  default     = 5
}

# --- FinOps & Cost Optimization ---
variable "cost_center" {
  description = "FinOps cost center for cost allocation tagging"
  type        = string
  default     = "DevOps-FinOps"
}

variable "owner" {
  description = "Resource owner for cost tracking"
  type        = string
  default     = "Gourob Das"
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days (reduced from 14 to 7 for FinOps cost reduction)"
  type        = number
  default     = 7
}

variable "alb_idle_timeout" {
  description = "ALB idle connection timeout in seconds (tuned to 30s to reclaim connection resources)"
  type        = number
  default     = 30
}

variable "enable_vpc_endpoints" {
  description = "Enable AWS VPC Endpoints to eliminate NAT Gateway data processing fees"
  type        = bool
  default     = true
}

variable "monthly_budget_limit" {
  description = "Monthly budget limit in USD for AWS Budgets cost alerting"
  type        = string
  default     = "50.0"
}

variable "budget_alert_email" {
  description = "Email address for AWS Budget notifications and cost alerts"
  type        = string
  default     = "gourobdas0103@gmail.com"
}

variable "ecs_autoscale_min_capacity" {
  description = "Minimum number of ECS tasks for auto-scaling"
  type        = number
  default     = 1
}

variable "ecs_autoscale_max_capacity" {
  description = "Maximum number of ECS tasks for auto-scaling"
  type        = number
  default     = 4
}

variable "ecs_cpu_target_utilization" {
  description = "Target average CPU utilization percentage for ECS auto-scaling"
  type        = number
  default     = 70.0
}

variable "ecs_memory_target_utilization" {
  description = "Target average Memory utilization percentage for ECS auto-scaling"
  type        = number
  default     = 80.0
}
