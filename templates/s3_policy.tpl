{
    "Statement": [
        {
            "Action": "s3:*",
            "Condition": {
                "StringEquals": {
                    "aws:sourceVpc": "${vpc_id}"
                }
            },
            "Effect": "Allow",
            "Principal": "*",
            "Resource": "arn:aws:s3:::${bucket_name}/*"
        }
    ],
    "Version": "2008-10-17"
}
