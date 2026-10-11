# Backend settings live in environments/<env>.backend.hcl and are passed to
# `terraform init -backend-config=...`. State is S3 with native locking
# (use_lockfile), which requires Terraform >= 1.10.
