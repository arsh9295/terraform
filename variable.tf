variable "bucket" {
  domainname = aws_s3_bucket.tf-bucket.bucket_regional_domain_name
}