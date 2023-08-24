variable "main-vpcid" {
  description = "VPC id of the Main account VPC."
  type        = string
  default     = "vpc-00b09e53c6e62a994"
}

variable "main-openvpn-sg-id" {
  description = "id of the OpenVPN Security Group in the Main account."
  type        = string
  default     = "sg-0b1ae2c7274d72b68"
}

variable "main-ec2-subnet-id" {
  description = "Subnet id for provisioning the EC2 Windows instances."
  type        = string
  default     = "subnet-0871b35cbe9d0c1cf"
}

variable "main-private-subnet-ids" {
  description = "Private Subnets in the Main account VPC."
  type        = list(string)
  default     = ["subnet-069a69e50bd1ebb23", "subnet-0871b35cbe9d0c1cf", "subnet-045bd90a8091ea930"]
}

variable "main-private-subnet-cidr-blocks" {
  description = "Private Subnet CIDR blocks in the Main account VPC."
  type        = list(string)
  #default     = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

