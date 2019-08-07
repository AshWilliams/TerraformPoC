/*
we recommend using
partial configuration with the "-backend-config" flag to "terraform init"
*/
provider "aws" {
  region = var.terraform_aws_region
}

##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
data "aws_vpc" "default" {
   default = true
}

# data "aws_subnet_ids" "all" {
#   vpc_id = "${data.aws_vpc.default.id}"
# }

# data "aws_security_group" "default" {
#   vpc_id = "${data.aws_vpc.default.id}"
#   name   = "default"
# }

resource "aws_security_group" "sg" {
  name = "${var.terraform_aws_sg}"
  vpc_id = "${data.aws_vpc.default.id}"
  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["${var.terraform_aws_sg_cidr_blocks}"]
  }
}

resource "aws_instance" "example" {
  ami           = "ami-36a86d5b" 
  instance_type = "z1d.large"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]

  tags = {
    Name = "${var.terraform_tags["Name"]}"
  }
}

// Address of the mssql DB instance.
output "aws_instance_private_ip" {
  value = "${aws_instance.example.private_ip}"
}