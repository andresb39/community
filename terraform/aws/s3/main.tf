provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket-jb"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Owner       = "Terraform"
  }
}

resource "aws_iam_user" "user_bucket" {
  name = "user-tf-bucket-test"

  tags = {
    Owner = "Terraform"
    Environment = "Dev"
  }
}

resource "aws_iam_access_key" "user_bucket" {
  user = aws_iam_user.user_bucket.name
}