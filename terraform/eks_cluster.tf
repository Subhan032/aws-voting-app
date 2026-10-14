# -----------------------------------------------------------------------------
# EKS Cluster IAM Role & Policy Attachments
# -----------------------------------------------------------------------------

resource "aws_iam_role" "cluster" {
  name = "${local.name_prefix}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-eks-cluster-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

# -----------------------------------------------------------------------------
# Amazon EKS Cluster
# -----------------------------------------------------------------------------

resource "aws_eks_cluster" "main" {
  name     = local.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    # Place control plane cross-account ENIs strictly into private subnets
    subnet_ids              = aws_subnet.private[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  # Enable all five core EKS control-plane log streams to CloudWatch
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Modern access config: avoids deprecated aws-auth ConfigMap while maintaining compatibility
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = merge(
    local.default_tags,
    {
      Name = local.cluster_name
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.cluster_vpc_resource_controller,
  ]
}

# -----------------------------------------------------------------------------
# Core EKS Add-ons
# -----------------------------------------------------------------------------
# Note: By omitting 'addon_version', AWS EKS dynamically resolves and provisions
# the default, officially supported compatible add-on versions for Kubernetes 1.35.
# This prevents version drift and stale hardcoded add-on strings.

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"

  tags = local.default_tags
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"

  tags = local.default_tags

  # CoreDNS runs as pods on worker nodes; ensure node group is available first
  depends_on = [aws_eks_node_group.main]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"

  tags = local.default_tags
}

