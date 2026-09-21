terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Change the region if you'd rather build somewhere other than us-east-1
provider "aws" {
  region = "us-east-1"
}

# IMPORTANT: S3 bucket names must be globally unique across ALL of AWS.
# Change this to something like "christianjones-devops-demo-2026" before running.
variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
  default     = "christianjones-devops-demo-2026"
}

# --- S3 bucket that will hold and serve the website files ---
resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name
}

# Allow public read access (required for a public static website)
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "site" {
  bucket     = aws_s3_bucket.site.id
  depends_on = [aws_s3_bucket_public_access_block.site]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.site.arn}/*"
    }]
  })
}

# Turn the bucket into a static website
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}

# Upload index.html automatically whenever its contents change
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/index.html")
}

# --- CloudFront distribution sitting in front of the S3 website ---
resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket_website_configuration.site.website_endpoint
    origin_id   = "s3-website-origin"

    custom_origin_config {
      http_port              = 80
      https_port              = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-website-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "s3_website_endpoint" {
  value = aws_s3_bucket_website_configuration.site.website_endpoint
}

output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.site.domain_name}"
}
