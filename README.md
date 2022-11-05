# aws-iam-user-policy-restrict-by-ip
Demo to show how to implement conditional restrictions based on the source IP address the request originated from.  The example will demonstrate how to limit privileges to the IAM user "terraform" from within the corresponding VPC CIDR range.

## Architecture
![alt text](https://github.com/gravelgrinder/aws-iam-user-policy-restrict-by-ip/blob/main/images/architecture-diagram.png?raw=true)

## Setup Steps
1. Run the following to Initialize the Terraform environment.

```
terraform init
```

2. Provision the resources in the Terraform scripts

```
terraform apply
```

3. From the output of the `terraform apply` use the djl-tf-server_ip value to SSH into the djl-tf-server. Note: Your IP address and key path might be different in your situation.
```
lwdvin@a483e7078b3f aws-iam-user-policy-restrict-by-ip % ssh ec2-user@10.0.101.26 -i /Users/lwdvin/Documents/SSH_Keys/DemoVPC_Key_Pair.pem
The authenticity of host '10.0.101.26 (10.0.101.26)' can't be established.
ED25519 key fingerprint is SHA256:71SbVui1u2G1uaoM50SfKnYzLpSX+/09xyfadBjTuY0.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.0.101.26' (ED25519) to the list of known hosts.

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
13 package(s) needed for security, out of 16 available
Run "sudo yum update" to apply all updates.
[ec2-user@ip-10-0-101-26 ~]$ 
```

4. Configure the "terraform" user profile on the djl-tf-server.
```
[ec2-user@ip-10-0-101-26 ~]$ aws configure --profile tf-user
AWS Access Key ID [None]: AKIA****************
AWS Secret Access Key [None]: vvTG**********************************5H
Default region name [None]: us-east-1
Default output format [None]: json
[ec2-user@ip-10-0-101-26 ~]$ 
```

5. Attempt to get the parameter from AWS Systems Manager Parameter Store

```
aws ssm get-parameter --profile "tf-user" --name /DEV/db1/username
```

6. The IAM policy only allows the permissions from the djl-tf-server (Terraform server) that was provisioned in this infrastructure stack.  Attempt to repeat steps #4 and #5 on another compute instance like your laptop.  Confirm you get an AccessDenied error code running the command on any other instance.
From the AWS cli
```
lwdvin@a483e7078b3f aws-iam-user-policy-restrict-by-ip % aws ssm get-parameter --profile "tf-user" --name /DEV/db1/username

An error occurred (AccessDeniedException) when calling the GetParameter operation: User: arn:aws:iam::614129417617:user/terraform is not authorized to perform: ssm:GetParameter on resource: arn:aws:ssm:us-east-1:614129417617:parameter/DEV/db1/username with an explicit deny in an identity-based policy
lwdvin@a483e7078b3f aws-iam-user-policy-restrict-by-ip % 
```

Here is an example of the CloudTrail AccessDenied event.
```
{
    "eventVersion": "1.08",
    "userIdentity": {
        "type": "IAMUser",
        "principalId": "AKIA****************",
        "arn": "arn:aws:iam::********7617:user/terraform",
        "accountId": "********7617",
        "accessKeyId": "AKIA****************",
        "userName": "terraform"
    },
    "eventTime": "2022-11-04T23:29:19Z",
    "eventSource": "ssm.amazonaws.com",
    "eventName": "GetParameter",
    "awsRegion": "us-east-1",
    "sourceIPAddress": "208.XX.XX.55",
    "userAgent": "aws-cli/2.4.11 Python/3.8.8 Darwin/21.6.0 exe/x86_64 prompt/off command/ssm.get-parameter",
    "errorCode": "AccessDenied",
    "errorMessage": "User: arn:aws:iam::********7617:user/terraform is not authorized to perform: ssm:GetParameter on resource: arn:aws:ssm:us-east-1:********7617:parameter/DEV/db1/username because no identity-based policy allows the ssm:GetParameter action",
    "requestParameters": null,
    "responseElements": null,
    "requestID": "6082ab77-0685-4334-a498-9db2d592a9a6",
    "eventID": "860b9f8c-1019-4217-971b-7f4407bf6bd5",
    "readOnly": true,
    "eventType": "AwsApiCall",
    "managementEvent": true,
    "recipientAccountId": "********7617",
    "eventCategory": "Management",
    "tlsDetails": {
        "tlsVersion": "TLSv1.2",
        "cipherSuite": "ECDHE-RSA-AES128-GCM-SHA256",
        "clientProvidedHostHeader": "ssm.us-east-1.amazonaws.com"
    }
}
```

Example of a successfull call to SSM
```
{
    "eventVersion": "1.08",
    "userIdentity": {
        "type": "IAMUser",
        "principalId": "AKIA****************",
        "arn": "arn:aws:iam::********7617:user/terraform",
        "accountId": "********7617",
        "accessKeyId": "AKIAY57HXHWIX5RO7OGW",
        "userName": "terraform"
    },
    "eventTime": "2022-11-04T23:50:12Z",
    "eventSource": "ssm.amazonaws.com",
    "eventName": "GetParameter",
    "awsRegion": "us-east-1",
    "sourceIPAddress": "10.0.101.246",
    "userAgent": "aws-cli/1.18.147 Python/2.7.18 Linux/5.10.144-127.601.amzn2.x86_64 botocore/1.18.6",
    "requestParameters": {
        "name": "/DEV/db1/username"
    },
    "responseElements": null,
    "requestID": "1d1839d6-faf0-42fb-b995-3429500ae1e6",
    "eventID": "8860c5a8-2c5d-4427-af59-2b786d9bab37",
    "readOnly": true,
    "resources": [
        {
            "accountId": "********7617",
            "ARN": "arn:aws:ssm:us-east-1:********7617:parameter/DEV/db1/username"
        }
    ],
    "eventType": "AwsApiCall",
    "managementEvent": true,
    "recipientAccountId": "********7617",
    "vpcEndpointId": "vpce-0cff38f1b13f73c65",
    "eventCategory": "Management",
    "tlsDetails": {
        "tlsVersion": "TLSv1.2",
        "cipherSuite": "ECDHE-RSA-AES128-GCM-SHA256",
        "clientProvidedHostHeader": "ssm.us-east-1.amazonaws.com"
    }
}
```

## Clean up Resources
1. To delete the resources created from the terraform script run the following.
```
terraform destroy
```

2. Remove the IAM user (terraform) credentials from any awscli credentials file you configured.  This step is only necessary if you configured credentials on an instance other than the one created from the terraform stack.


## Helpful Resources
* []()

## Questions & Comments
If you have any questions or comments on the demo please reach out to me [Devin Lewis - AWS Solutions Architect](mailto:lwdvin@amazon.com?subject=AWS%2FTerraform%20IAM%20User%20Policy%20Restrict%20by%20IP%20Address%20Demo%20%28aws-iam-user-policy-restrict-by-ip%29)

Of if you would like to provide personal feedback to me please click [Here](https://feedback.aws.amazon.com/?ea=lwdvin&fn=Devin&ln=Lewis)