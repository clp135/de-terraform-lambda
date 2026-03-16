import boto3
import csv
import urllib.parse

# Initialize the S3 client
s3 = boto3.client('s3')

def lambda_handler(event, context):
    # 1. Get the bucket name and file key from the S3 event
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    
    # URL decode the key to handle spaces or special characters
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    
    # Define the target bucket (make sure this matches your variable in Terraform)
    # Note: In a real scenario, you can pass this as an environment variable
    target_bucket = source_bucket.replace("-raw-", "-clean-")

    try:
        # 2. Fetch the object from S3
        response = s3.get_object(Bucket=source_bucket, Key=key)
        content = response['Body'].read().decode('utf-8').splitlines()
        
        # 3. Simple Validation: Check if the CSV header is "id,name,value"
        if content and content[0].strip() == "id,name,value":
            print(f"Validation Success for file: {key}")
            
            # 4. Copy the valid file to the target bucket with 'processed_' prefix
            copy_source = {'Bucket': source_bucket, 'Key': key}
            s3.copy_object(Bucket=target_bucket, CopySource=copy_source, Key=f"processed_{key}")
            
            return {
                'statusCode': 200,
                'body': f"File {key} processed and moved to {target_bucket}"
            }
        else:
            print(f"Validation Failed for file: {key}. Invalid header.")
            return {
                'statusCode': 400,
                'body': "Invalid CSV header format."
            }

    except Exception as e:
        print(f"Error processing object {key} from bucket {source_bucket}: {str(e)}")
        raise e