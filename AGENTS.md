# Project Rules: AWS Voting App

## Project Overview & Core Context
- **Project Scope**: Deployment of the Docker Samples Example Voting App to Amazon Web Services (AWS).
- **Target Repository**: `Subhan032/aws-voting-app`
- **AWS Region**: `ap-southeast-2`
- **AWS CLI Profile**: Use `new-account` for all local AWS CLI operations and scripting.

## Target Architecture
- **VPC & Networking**:
  - Spans two Availability Zones (AZs).
  - Public and private subnets across both AZs.
  - Single NAT Gateway (balancing cost and high availability for a portfolio project).
  - Internet-facing Application Load Balancer (ALB) in public subnets.
- **Compute & Workloads**:
  - Amazon Elastic Kubernetes Service (EKS) managed worker nodes deployed strictly in private subnets.
- **Container Registry & Deployment**:
  - Amazon Elastic Container Registry (ECR) for hosting application container images.
  - Terraform for all cloud infrastructure provisioning and management.
  - Plain Kubernetes manifests for application workloads.
  - GitHub Actions utilizing AWS OIDC federation for secure CI/CD pipelines.

## Workload & State Management (Redis & PostgreSQL)
- **Initial Setup**: Redis and PostgreSQL run initially as pods within Kubernetes.
- **Requirements & Considerations**:
  - **Persistent Storage**: Explicitly define and manage persistent storage requirements (e.g., EBS CSI Driver, StorageClasses, PVCs).
  - **Secret Handling**: Strictly decouple database credentials and connection strings from manifests; manage via Kubernetes Secrets or external secret management.
  - **Backups**: Explicitly design and document backup/restore strategies and disaster recovery considerations.
  - **Limitations**: Acknowledge and document the limitations of running stateful database instances directly inside Kubernetes worker nodes versus managed offerings (e.g., Amazon RDS / ElastiCache).

## Engineering Standards & Best Practices
- **Current & Supported Practices**: Follow current, supported, security-conscious AWS and Kubernetes practices. Never knowingly introduce deprecated resources, arguments, fields, APIs, actions, or configuration patterns.
- **Documentation Verification**: Verify current official documentation and release notes when version-sensitive behavior is involved. Do not claim something is current or supported without checking.
- **Portfolio Appropriate**: Prefer simple, maintainable, and cost-effective solutions appropriate for a junior Cloud/DevOps portfolio. Avoid unnecessary complexity or premature overengineering.
- **Incremental Changes**: Work incrementally. Inspect existing files before modifying them, preserve upstream application code, explain rationale for changes, and report validation results.
- **Conciseness**: Keep prompts, code comments, and generated documentation concise unless deep technical detail is specifically necessary.

## Security & Operational Guardrails
- **Credential Protection**: Never commit credentials, tokens, private keys, Terraform state, or real secret values into version control.
- **Approval Gate**: Never run `terraform apply`, destroy resources, or perform other billable or destructive AWS operations without explicit user approval.

