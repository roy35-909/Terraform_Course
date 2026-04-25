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
    profile = "Batch-8" 
}

resource "aws_vpc" "main" {
    cidr_block = "192.168.0.0/16"

    tags = {
        Name = "main-vpc"
    }
}

resource "aws_subnet" "public" {
    vpc_id= aws_vpc.main.id
    cidr_block = "192.168.1.0/24"
    availability_zone = "ap-south-1a"
    tags = {
        Name = "public-subnet"
    }
}

resource "aws_eip" "public_eip" {
    vpc = true
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

resource "aws_route" "default_route"{
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_access.id
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "private-route-table"
    }   
}




resource "aws_subnet" "private" {
    vpc_id= aws_vpc.main.id
    cidr_block = "192.168.2.0/24"
    availability_zone = "ap-south-1a"

    tags = {
        Name = "private-subnet"
    }
}



resource "aws_route_table_association" "public_rt_assoc" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_assoc" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "main_sg" {
    name = "main-sg"
    description = "Main security group"
    vpc_id = aws_vpc.main.id


    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.main_sg.id
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.main_sg.id

}

resource "aws_security_group_rule" "allow_https_inbound" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.main_sg.id
}

resource "aws_security_group_rule" "allow_icmp_inbound" {
    type = "ingress"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["192.168.0.0/16"]
    security_group_id = aws_security_group.main_sg.id
}




resource "aws_instance" "web_server" {
    ami                         = "ami-05d2d839d4f73aafb"
    instance_type               = "t2.micro"
    subnet_id                   = aws_subnet.public.id
    vpc_security_group_ids      = [aws_security_group.main_sg.id]
    key_name                    = "my_key"
    
    tags = {
        Name = "web-server-instance"
    }
}

resource "aws_eip_association" "web_server_eip" {
    instance_id   = aws_instance.web_server.id
    allocation_id = aws_eip.public_eip.id
}

resource "aws_instance" "database_server" {
    ami                         = "ami-05d2d839d4f73aafb"
    instance_type               = "t2.micro"
    subnet_id                   = aws_subnet.private.id
    vpc_security_group_ids      = [aws_security_group.main_sg.id]
    key_name                    = "my_key"

    tags = {
        Name = "database-server-instance"
    }
}

resource "aws_key_pair" "ssh_key" {
    key_name   = "test_aws"
    public_key = file("/home/roy/.ssh/test_aws.pub")
}

resource "aws_eip" "app_eip" {
    vpc = true
}




resource "aws_instance" "app_server" {
    ami                        = "ami-05d2d839d4f73aafb"
    instance_type               = "t2.micro"
    subnet_id                   = aws_subnet.public.id
    vpc_security_group_ids      = [aws_security_group.main_sg.id]
    key_name                    = aws_key_pair.ssh_key.key_name

    tags = {
        Name = "app-server-instance"
    }
}

resource "aws_eip_association" "app_server_eip" {
    instance_id   = aws_instance.app_server.id
    allocation_id = aws_eip.app_eip.id
}