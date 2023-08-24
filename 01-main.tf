### Consumer Account Resources
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}


### Resources necessary for Cross Account IAM Authentication to an RDS instance.

###############################################################################
### IAM Resources in the Service Providers account
###############################################################################
## Create IAM Policy for connecting to DB 
data "template_file" "iam_policy" {
  template = "${file("IAM/user-policy-v2.json")}"

  vars = { terraform_private_ip_address = "${aws_instance.djl-tf-server.private_ip}"}
}

data "template_file" "iam_trust_policy" {
  template = "${file("IAM/iam_trust_policy.json")}"

  vars = {}
}

resource "aws_iam_policy" "iac_user_policy" {
  name        = "tf_iac_iam_policy"
  description = "IAM Policy to allow the terraform to have * privilages when connecting from a specific IP address range."
  policy      = "${data.template_file.iam_policy.rendered}"
}

resource "aws_iam_role" "iac_iam_role" {
  name                = "tf_iac_iam_connect_role"
  assume_role_policy  = "${data.template_file.iam_trust_policy.rendered}"
  managed_policy_arns = [aws_iam_policy.iac_user_policy.arn]
}

### Create IAM User
resource "aws_iam_user" "iac_user" {
  name     = "terraform"
}

### Attach Policy to user
resource "aws_iam_user_policy_attachment" "iac_iam_user_policy_attachment" {
  user       = aws_iam_user.iac_user.name
  policy_arn = aws_iam_policy.iac_user_policy.arn
}

resource "aws_iam_access_key" "iac_iam_user" {
  user     = aws_iam_user.iac_user.name
}
###############################################################################


###############################################################################
### VPCE 
###############################################################################
resource "aws_security_group" "vpce" {
  name        = "tf_vpce_ssm"
  description = "Security Group for the VPC endpoint for the SSM service."
  vpc_id      = var.main-vpcid

  tags = {
    Name = "tf_vpce_ssm"
  }  
}
resource "aws_security_group_rule" "allow_vpce_ingress1" {
  type              = "ingress"
  description       = "Allow traffic from Terraform EC2"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  source_security_group_id = aws_security_group.ec2_sg1.id
  security_group_id = aws_security_group.vpce.id
}

resource "aws_security_group_rule" "allow_vpce_egress1" {
  type              = "egress"
  description       = "Allow all outbound connections"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpce.id
}


resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = var.main-vpcid
  service_name      = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.main-private-subnet-ids
  security_group_ids = [aws_security_group.vpce.id]

  private_dns_enabled = true
  tags = {
      Name        = "tf-vpce-ssm"
    }
}
###############################################################################


###############################################################################
### Create a Parameter to access in the AWS Systems Manager Parameter Store
###############################################################################
resource "aws_ssm_parameter" "sample-db-username" {
  name  = "/DEV/db1/username"
  type  = "String"
  value = "lwdvin"
}
###############################################################################