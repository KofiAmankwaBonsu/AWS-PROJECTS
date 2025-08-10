import json
import boto3
import os
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize S3 client
s3_client = boto3.client('s3')

def copy_object(source_bucket, source_key, destination_bucket):
    """Copy object from source to destination bucket"""
    try:
        s3_client.copy_object(
            CopySource={'Bucket': source_bucket, 'Key': source_key},
            Bucket=destination_bucket,
            Key=source_key
        )
        logger.info(f"Successfully copied {source_key} to {destination_bucket}")
        return True
    except Exception as e:
        logger.error(f"Error copying object {source_key}: {str(e)}")
        return False

def handler(event, context):
    """Lambda handler function"""
    try:
        # Get bucket names from environment variables
        source_bucket = os.environ['SOURCE_BUCKET']
        destination_bucket = os.environ['DESTINATION_BUCKET']

        # Log the incoming event
        logger.info(f"Received event: {json.dumps(event)}")
        
        processed_files = []
        failed_files = []

        # Process SQS records
        if 'Records' in event:
            for record in event['Records']:
                try:
                    # Parse the SQS message body which contains the S3 event
                    message_body = json.loads(record['body'])
                    
                    if 'Records' not in message_body:
                        logger.error("No Records in SQS message body")
                        continue
                    
                    # Get S3 event details
                    s3_event = message_body['Records'][0]
                    file_key = s3_event['s3']['object']['key']
                    
                    # Copy the object
                    if copy_object(source_bucket, file_key, destination_bucket):
                        processed_files.append(file_key)
                    else:
                        failed_files.append(file_key)
                    
                except Exception as e:
                    logger.error(f"Error processing record: {str(e)}")
                    if 'file_key' in locals():
                        failed_files.append(file_key)
                    continue

            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'File copying completed',
                    'processed_files': processed_files,
                    'failed_files': failed_files
                })
            }
        
        return {
            'statusCode': 400,
            'body': json.dumps('Invalid event structure')
        }

    except Exception as e:
        logger.error(f"Error in handler: {str(e)}")
        raise
