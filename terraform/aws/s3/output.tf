output "user" {
  value = aws_iam_user.lb.name
}
output "Access_key" {
  value = aws_iam_access_key.lb.id
}
output "secret_key" {
  value = aws_iam_access_key.lb.secret
}

output "bucket_arn" {
    value = aws_s3_bucket.b.arn
}