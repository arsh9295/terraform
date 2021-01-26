provider "aws" {
    region = var.awsregion
    access_key = var.accesskey
    secret_key = var.secretkey
}

resource "aws_s3_bucket" "tf-bucket" {
  bucket = var.awsbucketname
}

locals {
  s3_origin_id = "S3-${var.awsbucketname}"
}

# resource "aws_waf_web_acl" "waf_acl" {
#   depends_on = [
#     aws_waf_ipset.ipset,
#     aws_waf_rule.wafrule,
#   ]
#   name        = "tfWebACL"
#   metric_name = "tfWebACL"

#   default_action {
#     type = "ALLOW"
#   }

#   rules {
#     action {
#       type = "BLOCK"
#     }

#     priority = 1
#     rule_id  = aws_waf_rule.wafrule.id
#     type     = "REGULAR"
#   }
# }

# resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
#   comment = "Some comment"
# }

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.tf-bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_distribution.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
#   comment             = "Some comment"
  default_root_object = "index.html"

#   logging_config {
#     include_cookies = false
#     bucket          = "mylogs.s3.amazonaws.com"
#     prefix          = "myprefix"
#   }

#   aliases = ["mysite.example.com", "yoursite.example.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}