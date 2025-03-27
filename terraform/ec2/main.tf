terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
		}
	}
}

provider "aws" {
	region = file("${path.module}/../config/aws_region")
	access_key = file("${path.module}/../config/aws_key")
	secret_key = file("${path.module}/../config/aws_secret")
}

resource "aws_instance" "ec2" {
	ami = "ami-084568db4383264d4"  // Ubuntu Server 24.04 LTS
	instance_type = "t2.micro"
	vpc_security_group_ids = [ aws_security_group.ec2_security_group.id ]

	// Github must remain public for setup script to work
	user_data = file("${path.module}/setup.sh")

	tags = {
		Name = "swen-514-7-webserver"
	}
}

resource "aws_security_group" "ec2_security_group" {
	name = "swen-514-7-webserver-sg"
	vpc_id = aws_default_vpc.default_vpc.id
}

resource "aws_security_group_rule" "allow_http" {
	type = "ingress"
	cidr_blocks = [ "0.0.0.0/0" ]
	from_port = 80
	to_port = 80
	security_group_id = aws_security_group.ec2_security_group.id
	protocol = "tcp"
}

resource "aws_security_group_rule" "allow_ssh" {
	type = "ingress"
	cidr_blocks = [ "0.0.0.0/0" ]
	from_port = 22
	to_port = 22
	security_group_id = aws_security_group.ec2_security_group.id
	protocol = "tcp"
}

resource "aws_security_group_rule" "allow_react_server" {
	type = "ingress"
	cidr_blocks = [ "0.0.0.0/0" ]
	from_port = 3000
	to_port = 3000
	security_group_id = aws_security_group.ec2_security_group.id
	protocol = "tcp"
}

resource "aws_security_group_rule" "allow_outbound_traffic" {
	type = "egress"
	cidr_blocks = [ "0.0.0.0/0" ]
	from_port = 0
	to_port = 0
	security_group_id = aws_security_group.ec2_security_group.id
	protocol = "-1"
}

resource "aws_default_vpc" "default_vpc" { }

output "instance_ip_addr" {
	value = aws_instance.ec2.public_ip
}