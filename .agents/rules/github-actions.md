---
trigger: glob
globs: ".github/workflows/*.yml, .github/workflows/*.yaml"
description: "Secure GitHub Actions and AWS OIDC standards for this project."
---

# GitHub Actions & AWS OIDC Standards

- **Documentation & Standards**: Follow current GitHub Actions documentation and AWS OIDC guidance.
- **Action Pinning**: Pin third-party actions to verified full-length commit SHAs; add a short comment identifying the corresponding release.
- **Minimal Permissions**: Grant only the minimum required workflow permissions. Set permissions at workflow or job level deliberately.
- **OIDC Authentication**: Use AWS OIDC federation and short-lived credentials, not long-lived AWS access keys in GitHub secrets.
- **Trust Scoping**: Restrict AWS role trust to the intended repository and branch or protected deployment environment.
- **Secret & Output Hygiene**: Never print credentials, tokens, secret values, or sensitive environment variables.
- **Job Separation & Image Tagging**: Separate validation/build jobs from deployment jobs where appropriate. Use immutable image tags such as commit SHAs rather than relying solely on `latest`.
- **Concurrency & Deployment Controls**: Add concurrency controls and deployment approvals where appropriate, without introducing unnecessary complexity.
- **Validation Gates**: Validate YAML, inspect action versions and permissions, and test workflow logic before enabling deployments.
- **Execution Approval Guardrail**: Never trigger a billable deployment or infrastructure destruction without explicit approval.

