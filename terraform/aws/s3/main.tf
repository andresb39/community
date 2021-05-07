provider "aws" {
  region = "${var.region}"
  # si usan profile descomentar la siguiente linea
  # profile = "${var.profile}"
}

resource "aws_s3_bucket" "b" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Owner       = "Terraform"
  }
}

resource "aws_iam_user" "user_bucket" {
  name = "${var.user_name}"

  tags = {
    Owner = "Terraform"
    Environment = "Dev"
  }
}

resource "aws_iam_access_key" "user_bucket" {
  user = aws_iam_user.user_bucket.name
}
