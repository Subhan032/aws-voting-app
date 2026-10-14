variable "project_name" {
  description = "Name of the project used for naming and tagging resources."
  type        = string
  default     = "aws-voting-app"
}

variable "environment" {
  description = "Target deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for provisioning resources."
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_profile" {
  description = "AWS CLI profile for local operations. Set to null in CI environments using OIDC/environment credentials."
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per Availability Zone)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets reserved for EKS worker nodes (one per Availability Zone)."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Explicit list of Availability Zones. If null, the first two available AZs in the region will be dynamically selected."
  type        = list(string)
  default     = null
}

# -----------------------------------------------------------------------------
# Amazon EKS Cluster Configuration Variables
# -----------------------------------------------------------------------------

variable "kubernetes_version" {
  description = "Kubernetes version for the Amazon EKS cluster and node group."
  type        = string
  default     = "1.35"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of IPv4 CIDR blocks permitted to access the public EKS API endpoint. Must not be 0.0.0.0/0."
  type        = list(string)
  default     = ["198.51.100.1/32"] # TEST-NET-2 documentation placeholder; replace before deployment
}

# -----------------------------------------------------------------------------
# Amazon EKS Managed Node Group Configuration Variables
# -----------------------------------------------------------------------------

variable "node_instance_types" {
  description = "EC2 instance types for the EKS managed node group. Cost-conscious and compatible with x86 workloads."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Root disk size in GiB for each worker node (EBS gp3 volume)."
  type        = number
  default     = 20
}

# -----------------------------------------------------------------------------
# GitHub Actions CI/CD Configuration Variables
# -----------------------------------------------------------------------------

variable "github_repository" {
  description = "The target GitHub repository in <owner>/<repo> format for OIDC trust scoping."
  type        = string
  default     = "Subhan032/aws-voting-app"
}

variable "github_branch" {
  description = "The target Git branch permitted to assume the GitHub Actions deployment role."
  type        = string
  default     = "main"
}

variable "github_oidc_provider_arn" {
  description = "The ARN of the GitHub Actions OIDC provider. If null, dynamically constructed from caller account ID."
  type        = string
  default     = null
}

variable "target_kubernetes_namespace" {
  description = "The target Kubernetes namespace for scoped EKS workload deployments."
  type        = string
  default     = "voting-app"
}

