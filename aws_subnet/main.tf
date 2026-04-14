terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}


provider "aws" {
  region  = "ap-south-1"
  profile = "Batch-8"

}


resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "main-vpc"
  }

}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    "Name" = "main-subnet"
  }
}