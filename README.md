# AWS S3 Static Website with CloudFront

A static website hosted on Amazon S3 and served through a CloudFront CDN distribution, provisioned entirely with Terraform (Infrastructure as Code). The S3 bucket is fully private — content is only reachable through CloudFront, authenticated via Origin Access Control (OAC).

## Architecture

```
User → CloudFront (CDN, via OAC) → Private S3 bucket
```

- **S3** hosts the static site files. All public access is blocked at the bucket level.
- **CloudFront** sits in front of the bucket, serving content over HTTPS and caching requests at edge locations.
- **Origin Access Control (OAC)** authenticates CloudFront to S3 directly through the REST API, so the bucket never needs to be publicly readable. A bucket policy scoped to this specific CloudFront distribution's ARN is the only thing allowed to read from it.

## What's in this repo

| File | Purpose |
|---|---|
| `index.html` | Site content |
| `main.tf` | Terraform config provisioning the S3 bucket, CloudFront OAC, CloudFront distribution, and the scoped bucket policy |
| `.gitignore` | Keeps local Terraform state and provider files out of version control |

## Deploying with Terraform

```bash
terraform init     # downloads the AWS provider
terraform plan      # previews exactly what will be created
terraform apply     # creates the S3 bucket, OAC, and CloudFront distribution
```

Terraform prints the live CloudFront URL once `apply` finishes.

## 🔗 Live Deployment
👉 **[View the Live Website Here](https://d2ypt0wqvb2ii9.cloudfront.net)**

## Notes

Originally built manually through the AWS Console with a public S3 bucket, then re-implemented as Terraform-managed Infrastructure as Code. Origin Access Control was added as a follow-up improvement, removing public bucket access entirely.
