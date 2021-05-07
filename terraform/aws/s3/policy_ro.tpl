{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PolicyforS3RO",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "${bucket-arn}/*"
        }
    ]
}
