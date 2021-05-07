data "template_file" "iam-policy-template" {
    template = file("${var.policy}")

    vars = {
        bucket-arn = aws_s3_bucket.b.arn
    }
}


resource "aws_iam_user_policy" "lb_ro" {
  name = "test"
  user = aws_iam_user.user_bucket.name
  policy = data.template_file.iam-policy-template.rendered
}