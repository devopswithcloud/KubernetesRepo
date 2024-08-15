#!/bin/bash

# Description: This script creates a security group, allows all inbound traffic,
# and launches three EC2 instances: one master and two workers.
# Optionally, you can specify the instance type. The default is t3.medium.
# if issue with AMIID, do change it accordingly, i have taken north-virginia

# Set the default instance type
INSTANCE_TYPE=${1:-t3.medium}

# Get the default VPC ID
echo "Fetching the default VPC ID..."
DEFAULT_VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text)
echo "Default VPC ID: $DEFAULT_VPC_ID"

# Create the security group
echo "Creating the security group 'k8s-sg'..."
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name k8s-sg \
    --description "Security group for Kubernetes allowing all inbound traffic" \
    --vpc-id $DEFAULT_VPC_ID \
    --query "GroupId" --output text)
echo "Security Group ID: $SECURITY_GROUP_ID"

# Allow all inbound traffic to the security group
echo "Allowing all inbound traffic to 'k8s-sg'..."
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol -1 \
    --port -1 \
    --cidr 0.0.0.0/0
echo "Inbound rules set for 'k8s-sg'."

# Launch the master instance
echo "Launching the master instance with instance type $INSTANCE_TYPE..."
aws ec2 run-instances \
    --image-id ami-04a81a99f5ec58529 \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name july2024 \
    --security-group-ids $SECURITY_GROUP_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=master}]' \
    --region us-east-1
echo "Master instance launched."

# Launch the worker-1 instance
echo "Launching the worker-1 instance with instance type $INSTANCE_TYPE..."
aws ec2 run-instances \
    --image-id ami-04a81a99f5ec58529 \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name july2024 \
    --security-group-ids $SECURITY_GROUP_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=worker-1}]' \
    --region us-east-1
echo "Worker-1 instance launched."

# Launch the worker-2 instance
echo "Launching the worker-2 instance with instance type $INSTANCE_TYPE..."
aws ec2 run-instances \
    --image-id ami-04a81a99f5ec58529 \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name july2024 \
    --security-group-ids $SECURITY_GROUP_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=worker-2}]' \
    --region us-east-1
echo "Worker-2 instance launched."

echo "Script completed successfully."