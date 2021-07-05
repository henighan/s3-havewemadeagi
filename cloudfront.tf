
# cloudfront distribution
resource "aws_cloudfront_distribution" "agiyet_distribution" {
    origin {
        domain_name = "${aws_s3_bucket.agiyet_bucket.bucket_domain_name}"
        origin_id = "${var.DOMAIN}-origin"
    }

    enabled = true
    aliases = ["${var.DOMAIN}", "test.${var.DOMAIN}", "www.${var.DOMAIN}"]
    price_class = "PriceClass_100"
    comment = "havewemadeagiyet.com"
    default_root_object = "index.html"

    default_cache_behavior {
        allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "${var.DOMAIN}-origin"

        forwarded_values {
            query_string = true
            cookies {
                forward = "all"
            }
        }
        viewer_protocol_policy = "redirect-to-https"
        min_ttl                = 0
        default_ttl            = 1000
        max_ttl                = 86400
    }
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
    viewer_certificate {
        acm_certificate_arn = "${var.SSL_ARN}"
        ssl_support_method  = "sni-only"
        minimum_protocol_version = "TLSv1.1_2016" # set manually since TF default isnt correct
    }
}
