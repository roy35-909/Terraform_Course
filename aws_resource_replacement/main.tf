terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "Batch-8"

}


resource "aws_vpc" "main" {

  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "Main-VPC"
  }
}





resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "Web-Server"
  }
}