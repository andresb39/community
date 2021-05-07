output "user" {
  value = aws_iam_user.user_bucket.name
}
output "Access_key" {
  value = aws_iam_access_key.user_bucket.id
}
output "secret_key" {
  value = aws_iam_access_key.user_bucket.secret
}

output "bucket_arn" {
    value = aws_s3_bucket.b.arn
}