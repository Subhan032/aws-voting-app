# -----------------------------------------------------------------------------
# Amazon ECR Repositories for AWS Voting App Workloads
# -----------------------------------------------------------------------------

locals {
  ecr_repositories = toset([
    "${var.project_name}-vote",
    "${var.project_name}-result",
    "${var.project_name}-worker",
  ])
}

resource "aws_ecr_repository" "workloads" {
  for_each = local.ecr_repositories

  name                 = each.value
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    local.default_tags,
    {
      Name = each.value
    }
  )
}

# Cost-conscious lifecycle policy: expire untagged images after 1 day and retain the last 10 tagged images
resource "aws_ecr_lifecycle_policy" "workloads" {
  for_each   = aws_ecr_repository.workloads
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

