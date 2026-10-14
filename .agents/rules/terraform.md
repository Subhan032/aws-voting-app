---
trigger: glob
globs: "*.tf, *.tfvars, *.hcl"
description: "Terraform and AWS infrastructure standards for this project."
---

# Terraform & AWS Infrastructure Standards

- **Documentation & Version Verification**: Check current HashiCorp Terraform and AWS provider documentation before using version-sensitive resources or arguments.
- **Explicit Version Constraints**: Use explicit Terraform and provider version constraints appropriate to the configuration. Do not blindly select versions or assume older examples remain valid.
- **Dependency Lock File**: Commit `.terraform.lock.hcl`; never edit it manually.
- **Support & Deprecations**: Use current supported resources and arguments. Investigate and resolve deprecation warnings rather than suppressing them.
- **Modular & Clean Architecture**: Use reusable modules and clear naming where this improves maintainability, without overengineering.
- **Security & Least Privilege**: Apply least-privilege IAM, encryption where supported, private networking, secure defaults, and appropriate resource tags.
- **Secret Hygiene**: Keep secrets out of source control, outputs, plans shared publicly, and logs. Mark sensitive values appropriately; remember that sensitive marking alone does not prevent state storage.
- **State Management**: Configure remote state only after considering its security, encryption, locking, and bootstrap requirements. Never commit state files.
- **Validation & Quality Gates**: Use `terraform fmt -check`, `terraform init -backend=false` where suitable for syntax validation, `terraform validate`, TFLint, and security scanning where practical.
- **Plan Review**: Review plans for unexpected replacements, deletions, public exposure, and estimated cost before requesting approval.
- **Execution Approval Guardrail**: Never execute apply or destroy without explicit approval.

