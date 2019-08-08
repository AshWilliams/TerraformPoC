
variable "terraform_instance_count" {
  default = "2"
}

variable "terraform_instance_tags" {
  type = "list"
  default = ["Development", "UAT"]
}
variable "terraform_aws_region" {
  type        = "string"
  default     = "us-east-2"
}

variable "terraform_aws_ami" {
  type        = "string"
  default     = "ami-36a86d5b"
}

variable "terraform_aws_instance" {
  type        = "string"
  default     = "z1d.large"
}

variable "terraform_aws_sg" {
  type        = "string"
  default     = "SQL Server Security Group"
}

variable "terraform_aws_sg_cidr_blocks" {
  type        = "string"
  default     = ""
}

variable "terraform_tags" {
  type            = "map"
  default         = {
      Name      = "Terraform Example"
      Environment = "Development"
  }
}