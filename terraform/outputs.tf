# -----------------------------------------------------------------------------
# Foundation & Networking Outputs
# -----------------------------------------------------------------------------

output "aws_region" {
  description = "The configured AWS region."
  value       = var.aws_region
}

output "environment" {
  description = "The target environment."
  value       = var.environment
}

output "name_prefix" {
  description = "The standardized naming prefix for downstream resources."
  value       = local.name_prefix
}

output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs for the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs for the private subnets."
  value       = aws_subnet.private[*].id
}

output "availability_zones" {
  description = "List of Availability Zones used for subnet allocation."
  value       = local.azs
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway."
  value       = aws_nat_gateway.main.id
}

output "nat_public_ip" {
  description = "The Elastic IP address assigned to the NAT Gateway."
  value       = aws_eip.nat.public_ip
}

# -----------------------------------------------------------------------------
# Amazon EKS Cluster & Node Group Outputs
# -----------------------------------------------------------------------------

output "cluster_name" {
  description = "The name of the Amazon EKS cluster."
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the EKS cluster."
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "The endpoint URL for the Amazon EKS API server."
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "The Kubernetes version running on the EKS cluster."
  value       = aws_eks_cluster.main.version
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster."
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "node_group_arn" {
  description = "The Amazon Resource Name (ARN) of the managed node group."
  value       = aws_eks_node_group.main.arn
}

output "node_group_status" {
  description = "Status of the EKS managed node group."
  value       = aws_eks_node_group.main.status
}

# -----------------------------------------------------------------------------
# Amazon ECR & CI/CD Outputs
# -----------------------------------------------------------------------------

output "ecr_repository_urls" {
  description = "Map of ECR repository names to their repository URLs."
  value       = { for k, v in aws_ecr_repository.workloads : k => v.repository_url }
}

output "github_actions_role_arn" {
  description = "The Amazon Resource Name (ARN) of the dedicated GitHub Actions CI/CD IAM role."
  value       = aws_iam_role.github_actions.arn
}

