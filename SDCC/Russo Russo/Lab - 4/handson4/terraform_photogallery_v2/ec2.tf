terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

variable "my_sec_group" {
	type = string
	default = "sg-XXX"
}
variable "my_subnet" {
	type = string
	default = "XXXX-YYYY"
}
variable "key_name" {
	type = string
	default = "XXXX"
}

resource "aws_instance" "app_instance" {
  ami           = "ami-030e490c34394591b"   
  instance_type = "t2.micro"
  vpc_security_group_ids = [var.my_sec_group]
  subnet_id              = var.my_subnet
  key_name = var.key_name
  iam_instance_profile = aws_iam_instance_profile.app_profile.name
  tags = {
    Name = "SDCC"
  }
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "app_profile"
  role = aws_iam_role.ec2role.name
}

resource "aws_iam_role" "ec2role" {
  name = "ec2_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}


resource "aws_iam_policy" "my_policy" {
  name        = "test_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "my_policyAttach" {
  name       = "test-attachment"
  roles      = ["${aws_iam_role.ec2role.name}"]
  policy_arn = aws_iam_policy.my_policy.arn
}

