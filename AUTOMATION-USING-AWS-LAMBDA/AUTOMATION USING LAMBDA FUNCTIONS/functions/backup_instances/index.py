import boto3
import os
from datetime import datetime

ec2 = boto3.client('ec2')

def handler(event, context):
    # Get instance ID and retention days from environment variables
    instance_id = os.environ['INSTANCE_ID']
    retention_days = int(os.environ.get('RETENTION_DAYS', '7'))  # Default 7 days if not set
    
    try:
        # Get the instance's volumes
        volumes = ec2.describe_instances(InstanceIds=[instance_id])['Reservations'][0]['Instances'][0]['BlockDeviceMappings']
        
        # Create snapshot for each volume
        for volume in volumes:
            if 'Ebs' in volume:  # Check if it's an EBS volume
                volume_id = volume['Ebs']['VolumeId']
                
                # Create snapshot with retention tag
                snapshot = ec2.create_snapshot(
                    VolumeId=volume_id,
                    Description=f'Backup for instance {instance_id}',
                    TagSpecifications=[{
                        'ResourceType': 'snapshot',
                        'Tags': [
                            {'Key': 'Name', 'Value': f'Backup-{instance_id}'},
                            {'Key': 'RetentionDays', 'Value': str(retention_days)},
                            {'Key': 'CreatedOn', 'Value': datetime.now().strftime('%Y-%m-%d')}
                        ]
                    }]
                )
                print(f"Created snapshot {snapshot['SnapshotId']} for volume {volume_id} with {retention_days} days retention")
        
        # Clean up old snapshots
        response = ec2.describe_snapshots(
            Filters=[
                {'Name': 'tag:Name', 'Values': [f'Backup-{instance_id}']}
            ]
        )
        
        current_date = datetime.now()
        for snapshot in response['Snapshots']:
            # Get creation date of snapshot
            creation_date = snapshot['StartTime'].replace(tzinfo=None)
            age_days = (current_date - creation_date).days
            
            # Delete if older than retention days
            if age_days > retention_days:
                ec2.delete_snapshot(SnapshotId=snapshot['SnapshotId'])
                print(f"Deleted old snapshot {snapshot['SnapshotId']} ({age_days} days old)")
        
        return {
            'statusCode': 200,
            'body': f'Successfully created backup for instance {instance_id} with {retention_days} days retention'
        }
        
    except Exception as e:
        print(f"Error in backup process: {str(e)}")
        return {
            'statusCode': 500,
            'body': f'Error in backup process: {str(e)}'
        }
