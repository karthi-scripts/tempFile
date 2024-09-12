terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
   
}

# Configure the AWS Provider below line are not need to be add..
provider "aws" {
  region = "us-east-1"
}
#reference ID
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  #dedicated,default --

  tags = {
    Name = "MY-vpc"
  }
}

resource "aws_subnet" "pubsb" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
 availability_zone = "us-east-1a"
  tags = {
    Name = "My-Public-SubNet"
  }
}
resource "aws_subnet" "prisb" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "My-Private-SubNet"
  }
}
resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MY -Internet - Gateway"
  }
}
resource "aws_route_table" "public_routeTable" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_internet_gateway.id
  }


  tags = {
    Name = "Public Route Table"
  }
}
resource "aws_route_table_association" "public_route_asso" {
  subnet_id      = aws_subnet.pubsb.id
  route_table_id = aws_route_table.public_routeTable.id
}

resource "aws_eip" "my_eIP" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.my_eIP.id
  subnet_id     = aws_subnet.pubsb.id

  tags = {
    Name = "MY NAT GATEWAY"
  }

}


resource "aws_route_table" "private_routeTable" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my_nat.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "private_route_asso" {
  subnet_id      = aws_subnet.prisb.id
  route_table_id = aws_route_table.private_routeTable.id
}




resource "aws_security_group" "allow_all" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_all" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_instance" "Karthi-Instance" {
    ami  = "ami-0e86e20dae9224db8"
    instance_type  ="t2.micro"
    subnet_id = aws_subnet.pubsb.id
    vpc_security_group_ids = [aws_security_group.allow_all.id]
    key_name = "Siva"
}






