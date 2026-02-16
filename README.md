## Screenshots

### S3 Bucket
![Bucket](s3Bucket.png)

### Bucket Contents
![Contents](bucketContents.png)

### Static Hosting Enabled
![Hosting](static-hosting-enabled.png)

### Website Live
![Website](website-live.png)

### CloudFront CDN Integration
![CloudFront Distribution](cloudFrontDistribution.png)

## Architecture Upgrade: Private S3 with CloudFront OAC

Secured the S3 bucket by removing public access and configuring CloudFront Origin Access Control (OAC). The website is now only accessible through CloudFront.

Architecture:

User → CloudFront → Private S3 bucket

Security improvement:
- Removed public read access
- Implemented Origin Access Control
- Prevented direct S3 access

Result:
Production-level secure static website hosting.

