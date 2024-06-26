resource "aws_s3_bucket" "bucket" { 
	bucket = "bao-test-website" 
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_policy     = false
  restrict_public_buckets = false
  block_public_acls = false
  ignore_public_acls = false
}

resource "aws_s3_bucket_policy" "bucket_policy" { 
bucket = aws_s3_bucket.bucket.id 
policy = jsonencode( 
	{ 
		"Version" : "2012-10-17", 
		"Statement" : [ 
			{
				"Sid" : "PublicReadGetObject", 
				"Effect" : "Allow", 
				"Principal" : "*", 
				"Action" : "s3:GetObject", 
				"Resource" : "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*" 
			} 
		] 
	} 
    )
}

# # Each file from the content directory will be uploaded as an S3 object
resource "aws_s3_object" "file" { 
	for_each = fileset(path.module, "content/**/*.{html,css,js}") 
	bucket = aws_s3_bucket.bucket.id 
	key = replace(each.value, "/^content//", "") 
	source = each.value 
	content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), null) 
	etag = filemd5(each.value) 
}


# # This configuration is sufficient to host your website publicly.
resource "aws_s3_bucket_website_configuration" "hosting" { 
	bucket = aws_s3_bucket.bucket.id 
	index_document { 
		suffix = "index.html" 
	} 
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket_website_configuration.hosting.website_endpoint
    origin_id   = aws_s3_bucket.bucket.bucket_regional_domain_name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

# viewer_certificate (Required) - The SSL configuration for this distribution (maximum one).
  viewer_certificate {
    cloudfront_default_certificate = true
  }

# restrictions (Required) - The restriction configuration for this distribution (maximum one).
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
# default_cache_behavior (Required) - Default cache behavior for this distribution (maximum one). 
#Requires either cache_policy_id (preferred) or forwarded_values (deprecated) be set.
  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.bucket.bucket_regional_domain_name
  }
}

