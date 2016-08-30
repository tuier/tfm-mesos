{
  "Statement": [
  {
    "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::${bucket_name}/*",
      "Condition": {
        "StringEquals": {
          "aws:sourceVpc": "${vpc_id}"
        }
      }
  }
  ]
}
