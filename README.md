# AWS S3 Static Website with CloudFront

A static website hosted on Amazon S3 and served through a CloudFront CDN distribution — built first manually through the AWS Console, then re-implemented as Infrastructure as Code with Terraform.

## Architecture

```
User → CloudFront (CDN) → S3 bucket (static website hosting, public read)
```

- **S3** hosts the static site files and is configured for static website hosting (`index.html` as the index document).
- **CloudFront** sits in front of the bucket, serving content over HTTPS and caching requests at edge locations.
- The bucket allows public `GetObject` access. This is required because CloudFront is pointed at the S3 **website endpoint** rather than the S3 REST API — the website endpoint only serves plain HTTP and doesn't support CloudFront's authenticated origin access (OAC), so the bucket has to be publicly readable for this configuration to work.

## What's in this repo

| File | Purpose |
|---|---|
| `index.html` / `test.html` | Site content |
| `main.tf` | Terraform config that provisions the S3 bucket, bucket policy, website hosting config, and CloudFront distribution |
| `.gitignore` | Keeps local Terraform state files out of version control |
| `*.png` | Screenshots of the build process (see below) |

## Deploying with Terraform

```bash
terraform init    # downloads the AWS provider
terraform plan     # previews exactly what will be created
terraform apply    # creates the S3 bucket + CloudFront distribution
```

Terraform outputs the live CloudFront URL once `apply` finishes.

## Planned improvements

- **Origin Access Control (OAC):** Currently the bucket is public because CloudFront targets the S3 website endpoint. A more secure pattern is pointing CloudFront at the S3 REST endpoint instead and using OAC to authenticate — this removes the need for any public bucket policy and keeps the bucket fully private end-to-end. Deliberately left as a next step rather than implemented here.

