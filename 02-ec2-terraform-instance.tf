###############################################################################
### djl-tf-server
###############################################################################
resource "aws_security_group" "ec2_sg1" {
  name        = "tf_sg1"
  description = "Security Group for djl-tf-server. Created by Terraform"
  vpc_id      = var.main-vpcid

  tags = {
    Name = "tf_sg1"
  }  
}

resource "aws_security_group_rule" "allow_ssh_ingress1" {
  type              = "ingress"
  description       = "Allow SSH Connections from the OpenVPN Server SG"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = var.main-openvpn-sg-id
  security_group_id = aws_security_group.ec2_sg1.id
}

resource "aws_security_group_rule" "allow_egress1" {
  type              = "egress"
  description       = "Allow all outbound connections"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg1.id
}

resource "aws_instance" "djl-tf-server" {
  ami                         = "ami-09d3b3274b6c5d4aa" # us-east-1
  instance_type               = "t3.large"
  subnet_id                   = var.main-ec2-subnet-id
  #availability_zone          = "us-east-1"
  associate_public_ip_address = "false"
  key_name                    = "DemoVPC_Key_Pair"
  vpc_security_group_ids      = [aws_security_group.ec2_sg1.id]
  #get_password_data           = "true"

  tags = {
    Name = "djl-tf-server"
  }
}
###############################################################################