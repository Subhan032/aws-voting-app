locals {
  name_prefix  = "${var.project_name}-${var.environment}"
  cluster_name = "${local.name_prefix}-eks"

  # Dynamically select the first two available AZs if not explicitly overridden
  azs = var.availability_zones != null ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)

  default_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Repository  = "Subhan032/aws-voting-app"
  }
}
