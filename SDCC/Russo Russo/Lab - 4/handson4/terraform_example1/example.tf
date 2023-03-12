terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.65"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}





variable "my_sec_group" {
	type = string
	default = "sg-04bb959b72d9abf77"
}
variable "my_subnet" {
	type = string
	default = "subnet-05dbf502122ae37a1"
}

resource "aws_instance" "example" {
  ami           = "ami-076309742d466ad69"   
  instance_type = "t2.small"
  vpc_security_group_ids = [var.my_sec_group]
  subnet_id              = var.my_subnet
  tags = {
    Name = "SDCC 22"
  }
}

