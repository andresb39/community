{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PolicyforS3RW",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": "${bucket-arn}/*"
        }
    ]
}
