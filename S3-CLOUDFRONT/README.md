# S3-CloudFront Video Streaming Infrastructure

A Terraform project that creates a scalable video streaming solution using AWS S3 and CloudFront. This infrastructure hosts both a website and video content with optimized delivery through CloudFront CDN.

## Architecture Overview

This project creates:
- **Two S3 buckets**: One for website hosting, one for video storage
- **CloudFront distribution**: Global CDN for fast content delivery
- **Origin Access Control (OAC)**: Secure access to S3 buckets
- **CORS configuration**: Enables cross-origin video streaming
- **Static website**: HTML page with video player

## Features

- ✅ Secure S3 bucket access via CloudFront OAC
- ✅ Global content delivery with CloudFront
- ✅ CORS-enabled video streaming
- ✅ Automatic static file deployment
- ✅ Optimized caching for different content types
- ✅ HTTPS-only access with redirect
- ✅ Modular Terraform architecture

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with permissions for S3, CloudFront, and IAM

## Quick Start

1. **Clone and navigate to the project**:
   ```bash
   cd s3-cloudfront
   ```

2. **Configure variables**:
   Edit `terraform.tfvars`:
   ```hcl
   aws_region          = "us-east-1"
   website_bucket_name = "my-website-bucket"
   video_bucket_name   = "my-video-bucket"
   
   tags = {
     Environment = "Production"
     Project     = "VideoStreaming"
   }
   ```

3. **Initialize and deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Upload your video**:
   ```bash
   aws s3 cp your-video.mp4 s3://your-video-bucket-randomsuffix/video.mp4
   ```

5. **Access your site**:
   Use the CloudFront domain name from the output.

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `website_bucket_name` | Name for website S3 bucket | `"my-website-bucket"` |
| `video_bucket_name` | Name for video S3 bucket | `"my-video-bucket"` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `"us-east-1"` |
| `tags` | Resource tags | `{}` |
| `content_types` | File extension to MIME type mapping | See variables.tf |

## Project Structure

```
s3-cloudfront/
├── main.tf                 # Main infrastructure configuration
├── variables.tf            # Variable definitions
├── outputs.tf             # Output values
├── terraform.tf           # Backend configuration
├── terraform.tfvars       # Variable values
├── modules/
│   ├── s3_video/          # Video bucket module
│   └── s3_website/        # Website bucket module
└── static/
    ├── index.html.tftpl   # Website template
    └── style.css          # Stylesheet
```

## Modules

### s3_video Module
Creates and configures the video storage bucket with:
- S3 bucket with public access blocked
- CloudFront Origin Access Control
- Secure bucket policies

### s3_website Module
Creates and configures the website hosting bucket with:
- S3 bucket with website configuration
- Static file deployment
- Content type detection

## Outputs

After deployment, you'll get:

| Output | Description |
|--------|-------------|
| `cloudfront_domain_name` | CloudFront distribution URL |
| `website_bucket_name` | Generated website bucket name |
| `video_bucket_name` | Generated video bucket name |
| `random_suffix` | Random suffix added to bucket names |

## Usage

### Uploading Videos

Upload videos to the video bucket:
```bash
aws s3 cp video.mp4 s3://$(terraform output -raw video_bucket_name)/video.mp4
```

### Customizing the Website

1. Edit `static/index.html.tftpl` to modify the website template
2. Add CSS files to `static/` directory
3. Run `terraform apply` to deploy changes

### Adding Custom Domain

To use a custom domain:
1. Add Route 53 hosted zone
2. Request SSL certificate in ACM
3. Update CloudFront distribution configuration

## Security Features

- **Private S3 buckets**: No public access allowed
- **Origin Access Control**: CloudFront-only access to S3
- **HTTPS enforcement**: All traffic redirected to HTTPS
- **CORS configuration**: Controlled cross-origin access

## Cost Optimization

- CloudFront caching reduces S3 requests
- Compression enabled for faster delivery
- Appropriate TTL settings for different content types

## Troubleshooting

### Common Issues

1. **Video not loading**: Check CORS configuration and video file upload
2. **Access denied**: Verify bucket policies and OAC configuration
3. **Slow loading**: Check CloudFront cache behaviors

### Debugging Commands

```bash
# Check bucket contents
aws s3 ls s3://$(terraform output -raw video_bucket_name)/

# Test CloudFront distribution
curl -I https://$(terraform output -raw cloudfront_domain_name)

# View Terraform state
terraform show
```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Note**: Empty S3 buckets before destroying to avoid errors.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request
