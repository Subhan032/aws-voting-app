# -----------------------------------------------------------------------------
# GitHub Actions CI/CD IAM Role & OIDC Trust Policy
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

locals {
  github_oidc_provider_arn = var.github_oidc_provider_arn != null ? var.github_oidc_provider_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_actions" {
  name = "${local.name_prefix}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.github_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:ref:refs/heads/${var.github_branch}"
          }
        }
      }
    ]
  })

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-github-actions-role"
    }
  )
}

# -----------------------------------------------------------------------------
# Least-Privilege IAM Policy for ECR Push & EKS Cluster Authentication
# -----------------------------------------------------------------------------

resource "aws_iam_policy" "github_actions_deploy" {
  name        = "${local.name_prefix}-github-actions-deploy-policy"
  description = "Least-privilege policy allowing GitHub Actions to push images to ECR and authenticate to EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAuthToken"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRRepositoryPushPull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = [for repo in aws_ecr_repository.workloads : repo.arn]
      },
      {
        Sid    = "EKSClusterAccess"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:UpdateClusterConfig"
        ]
        Resource = aws_eks_cluster.main.arn
      }
    ]
  })

  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}

# -----------------------------------------------------------------------------
# EKS Cluster Access Entry & Namespace-Scoped Policy Association
# -----------------------------------------------------------------------------

resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_iam_role.github_actions.arn
  type          = "STANDARD"

  tags = local.default_tags
}

resource "aws_eks_access_policy_association" "github_actions" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
  principal_arn = aws_iam_role.github_actions.arn

  access_scope {
    type       = "namespace"
    namespaces = [var.target_kubernetes_namespace]
  }

  depends_on = [aws_eks_access_entry.github_actions]
}

