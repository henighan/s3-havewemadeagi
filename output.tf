output "bucket_endpoint" {
  value = aws_s3_bucket.agiyet_bucket.website_endpoint
}


output "cloudfront_endpoint" {
  value = aws_cloudfront_distribution.agiyet_distribution.domain_name
}
