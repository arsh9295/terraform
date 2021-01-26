provider "aws" {
    region = var.awsregion
    access_key = var.accesskey
    secret_key = var.secretkey
}

module "s3bucket" {
  source = "s3"
}

module "cloudfront" {
  source = "cloudfront"
  domain_name = ["${aws_s3_bucket.tf-bucket.bucket_regional_domain_name}"]
}