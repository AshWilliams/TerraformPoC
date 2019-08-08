/*
we recommend using
partial configuration with the "-backend-config" flag to "terraform init"
*/
provider "aws" {
  region = var.terraform_aws_region
}

#backend make sure to change bucket name 
# terraform {
#   backend "s3" {
#     bucket = "tfbackendasu"
#     key    = "terraform/dev/terraform_dev.tfstate"
#     dynamodb_table = "terraform-state-locking"
#     encrypt = true # Optional, S3 Bucket Server Side Encryption
#     region = "us-east-2"
#   }
# }

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
  count         = "${var.terraform_instance_count}"
  ami           = "ami-36a86d5b" 
  instance_type = "z1d.large"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  tags = {
    Name = "${element(var.terraform_instance_tags, count.index)}"
  }
}

// Address of the mssql DB instance.
output "aws_instance_private_ip_dev" {
  value = "${aws_instance.example[0].private_ip}"
}

output "aws_instance_private_ip_qa" {
  value = "${aws_instance.example[1].private_ip}"
}