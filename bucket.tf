resource "aws_s3_bucket" "agiyet_bucket" {
  bucket = var.BUCKET_NAME
  acl    = "public-read"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.BUCKET_NAME}/*"
            ]
        }
    ]
}
EOF
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  tags = {
    Name = var.BUCKET_NAME
  }
}

resource "aws_s3_bucket_object" "index_file" {
  bucket = var.BUCKET_NAME
  key    = "index.html"
  source = "index.html"
  content_type = "text/html"
  etag = filemd5("index.html")
}


resource "aws_s3_bucket_object" "error_file" {
  bucket = var.BUCKET_NAME
  key    = "error.html"
  source = "error.html"
  content_type = "text/html"
  etag = filemd5("error.html")
}
