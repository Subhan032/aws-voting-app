# -----------------------------------------------------------------------------
# EKS Worker Node IAM Role & Policy Attachments
# -----------------------------------------------------------------------------

resource "aws_iam_role" "nodes" {
  name = "${local.name_prefix}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-eks-node-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# -----------------------------------------------------------------------------
# Node Launch Template (Encrypted EBS Root Volume & Tags)
# -----------------------------------------------------------------------------

resource "aws_launch_template" "nodes" {
  name_prefix = "${local.name_prefix}-node-"
  description = "Launch template for ${local.name_prefix} EKS managed worker nodes with encrypted root volume"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.node_disk_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.default_tags,
      {
        Name = "${local.name_prefix}-node"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      local.default_tags,
      {
        Name = "${local.name_prefix}-node-volume"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# EKS Managed Node Group
# -----------------------------------------------------------------------------
# COST & OPERATIONAL NOTE:
# EC2 worker instances (t3.medium) and attached EBS gp3 volumes incur hourly charges
# while running. A desired size of 2 distributes pods across both Availability Zones
# for portfolio reliability while controlling compute expenditure.
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.name_prefix}-default-nodes"
  node_role_arn   = aws_iam_role.nodes.arn
  version         = var.kubernetes_version

  # Strictly private subnets: worker nodes do NOT receive public IP addresses
  subnet_ids = aws_subnet.private[*].id

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  instance_types = var.node_instance_types
  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"

  launch_template {
    id      = aws_launch_template.nodes.id
    version = aws_launch_template.nodes.latest_version
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-default-node-group"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_policy,
  ]
}
