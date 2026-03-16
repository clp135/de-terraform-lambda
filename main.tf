# AWS Provider configuration for the Seoul region
provider "aws" {
  region = "ap-northeast-2"
}

# S3 bucket to store incoming raw CSV data
resource "aws_s3_bucket" "raw_data" {
  bucket        = var.raw_bucket_name
  force_destroy = true # Automatically deletes objects when destroying the bucket
}

# S3 bucket to store processed results
resource "aws_s3_bucket" "clean_data" {
  bucket        = var.clean_bucket_name
  force_destroy = true
}

# IAM Role that the Lambda function will assume
resource "aws_iam_role" "lambda_role" {
  name = "ybigta_lambda_role"

  # Trust policy allowing the Lambda service to use this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy defining specific S3 and CloudWatch permissions
resource "aws_iam_policy" "lambda_policy" {
  name        = "ybigta_lambda_s3_policy"
  description = "Permissions for S3 access and CloudWatch logging"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # S3 read/write permissions for specific buckets
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.raw_bucket_name}",
          "arn:aws:s3:::${var.raw_bucket_name}/*",
          "arn:aws:s3:::${var.clean_bucket_name}",
          "arn:aws:s3:::${var.clean_bucket_name}/*"
        ]
      },
      {
        # Permissions to create and write execution logs
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attachment connecting the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}