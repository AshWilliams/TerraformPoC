#!/bin/bash
#Usage ./images.sh RHEL-7.4_HVM_GA-20170808-x86_64-2-Hourly2-GP2
if [ -z "$1" ] ; then
    echo "Please pass the name of the AMI"
    exit 1
fi

IMAGE_FILTER="${1}"
r="us-east-2"
ami=$(aws ec2 describe-images --query 'Images[*].[ImageId]' --filters "Name=name,Values=${IMAGE_FILTER}" --region ${r} --output json)
echo $ami
