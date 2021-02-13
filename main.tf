provider "aws" {
  shared_credentials_file = "credentials"
  profile = "default"
  region = "ap-south-1"
}

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default = "10.1.0.0/16"
}

variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default = "10.1.0.0/24"
}

variable "availability_zone" {
    description = "avalaiblity zone to create subnet"
    default = "ap-south-1a"
}

variable "publc_key_path" {
  description = "Public key path"
  default = "~/.ssh/pubfile.pub"
}

variable "instance_ami" {
  description = "AMI for aws EC2 instance"
  default = "ami-09a7bbd08886aafdf"
}

variable "instance_type" {
  description = "type for aws Ec2 instance"
  default = "t2.micro"
}

variable "environment_tag" {
  description = "Environment tag"
  default = "Production"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_vpc}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
      "Environment" ="${var.environment_tag}"
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id ="${aws_vpc.vpc.id}"
  cidr_block = "${var.cidr_subnet}"
  map_public_ip_on_launch = true
  availability_zone = "${var.availability_zone}"
  tags = {
    "Environment" = "${var.environment_tag}"
  }

}
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id ="${aws_vpc.vpc.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id ="${aws_internet_gateway.igw.id}"
  }
  tags = {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
    subnet_id = "${aws_subnet.subnet_public.id}"
    route_table_id = "${aws_route_table.rtb_public.id}"
}

resource "aws_security_group" "sg_22" {
  name = "sg_22"
  description = "Allow Tcp inbound traffic"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    description = "TCP from VCP"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  } 

  egress {
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
  }

  tags = {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_key_pair" "ec2key" {
  key_name = "publicKey"
  public_key = "${file(var.publc_key_path)}"
}

resource "aws_instance" "testInstance" {
    ami = "${var.instance_ami}"
    instance_type = "${var.instance_type}"
    subnet_id = "${aws_subnet.subnet_public.id}"
    vpc_security_group_ids = ["${aws_security_group.sg_22.id}"]
    key_name = "${aws_key_pair.ec2key.key_name}"

    tags = {
      "Environment" = "${var.environment_tag}"
    }
  
}

