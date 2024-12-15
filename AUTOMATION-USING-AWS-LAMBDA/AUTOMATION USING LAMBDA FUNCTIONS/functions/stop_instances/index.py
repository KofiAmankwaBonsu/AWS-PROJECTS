import boto3
import os

ec2 = boto3.client('ec2')

def handler(event, context):
    
    instance_id = os.environ['INSTANCE_ID']
    
    try:
        ec2.stop_instances(InstanceIds=[instance_id])
        print(f"Successfully stopped instance: {instance_id}")
        return {
            'statusCode': 200,
            'body': f'Successfully stopped instance {instance_id}'
        }
    except Exception as e:
        print(f"Error stopping instance: {str(e)}")
        return {
            'statusCode': 500,
            'body': f'Error stopping instance: {str(e)}'
        }
