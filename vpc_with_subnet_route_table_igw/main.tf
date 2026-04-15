terraform {
  
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>4.0"
    }
  }
}


provider "aws" {
    region  = "ap-south-1"
    profile = "Batch-11" 
}


resource "aws_vpc" "main" {
    cidr_block = "192.168.0.0/16"
    tags = {
        Name = "main-vpc"
    }
}

resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "192.168.1.0/24"
    availability_zone       = "ap-south-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "public-subnet"
    }
}

resource "aws_internet_gateway" "internet_access" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "main-igw"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "public-route-table"
    }
}

resource "aws_route" "default_route" {
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_access.id  
}

resource "aws_route_table_association" "public_rt_assoc" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public_rt.id
}


resource "aws_security_group" "web_sg" {
    name        = "web-server-sg"
    description = "Allow SSH inbound traffic"
    vpc_id      = aws_vpc.main.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "web-server-sg"
    }
}

resource "aws_instance" "web_server" {
    ami                         = "ami-05d2d839d4f73aafb"
    instance_type               = "t2.micro"
    subnet_id                   = aws_subnet.public.id
    associate_public_ip_address = true
    vpc_security_group_ids      = [aws_security_group.web_sg.id]

    tags = {
        Name = "web-server"
    }
}


