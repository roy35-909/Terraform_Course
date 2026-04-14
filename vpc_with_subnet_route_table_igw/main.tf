terraform {
  
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>4.0"
    }
  }
}


provider "aws" {
    region  = "eu-west-1"
    profile = "Batch-8" 
}


resource "aws_vpc" "main" {
    cidr_block = "192.168.0.0/16"
    tags = {
        Name = "main-vpc"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = "192.168.1.0/24"
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


resource "aws_instance" "web_server" {
    ami = "ami-0f71aec9381dcafd1"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public.id
    tags = {
        Name = "web-server"
    }
}