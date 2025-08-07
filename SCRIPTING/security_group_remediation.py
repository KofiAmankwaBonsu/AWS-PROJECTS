import json
import boto3
import os
#from pattern_alerting import integrate_with_security_monitoring

ec2 = boto3.client('ec2')
sns = boto3.client('sns')

# Target ports: SSH, MySQL, SMTP
TARGET_PORTS = [22, 3306, 25]
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')

def lambda_handler(event, context):
    scan_and_remediate()
    
    #  Run pattern analysis for security logs
    # try:
    #     integrate_with_security_monitoring()
    # except Exception as e:
    #     print(f"Pattern analysis failed: {e}")
    
    # return {'statusCode': 200, 'body': 'Scan completed'}

def scan_and_remediate():
    # Get all running instances
    instances = ec2.describe_instances(
        Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
    )
    
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            
            # Check each security group attached to this instance
            for sg_ref in instance['SecurityGroups']:
                sg_id = sg_ref['GroupId']
                sg_details = ec2.describe_security_groups(GroupIds=[sg_id])['SecurityGroups'][0]
                
                risky_rules = find_risky_rules(sg_details)
                if risky_rules:
                    remove_rules(sg_id, risky_rules)
                    send_alert(instance_id, sg_id, sg_details.get('GroupName', 'Unknown'), risky_rules)

def find_risky_rules(security_group):
    risky_rules = []
    
    for rule in security_group.get('IpPermissions', []):
        from_port = rule.get('FromPort')
        to_port = rule.get('ToPort')
        
        if from_port is not None and to_port is not None:
            for target_port in TARGET_PORTS:
                if from_port <= target_port <= to_port:
                    for ip_range in rule.get('IpRanges', []):
                        if ip_range.get('CidrIp') == '0.0.0.0/0':
                            risky_rules.append(rule)
                            break
    
    return risky_rules

def remove_rules(group_id, risky_rules):
    ec2.revoke_security_group_ingress(
        GroupId=group_id,
        IpPermissions=risky_rules
    )

def send_alert(instance_id, group_id, group_name, rules):
    if SNS_TOPIC_ARN:
        message = f"SECURITY ALERT: Fixed instance {instance_id}\nRemoved {len(rules)} risky rules from security group {group_id} ({group_name}).\nPorts 22, 3306, or 25 were open to 0.0.0.0/0."
        
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=f'Instance Security Fixed: {instance_id}',
            Message=message
        )