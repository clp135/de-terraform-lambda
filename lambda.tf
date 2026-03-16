# 1. Archive the Python source code into a ZIP file
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/lambda_function.py"
  output_path = "${path.module}/src/lambda_function.zip"
}

# 2. Define the Lambda function and upload the ZIP file
resource "aws_lambda_function" "csv_processor" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "ybigta-csv-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  # Only re-upload if the source code changes
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Ensure IAM permissions are attached before creating the function
  depends_on = [aws_iam_role_policy_attachment.lambda_attach]
}

# 3. Grant S3 permission to invoke this Lambda function
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_data.arn
}

# 4. Configure S3 bucket notification to trigger Lambda on file upload
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.raw_data.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv" # Trigger only for CSV files
  }

  # Ensure permission is granted before setting up the notification
  depends_on = [aws_lambda_permission.allow_s3]
}