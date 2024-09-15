terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"

}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "jenkins" {
  ami  = "ami-0e86e20dae9224db8"
   # Replace with your preferred AMI ID
  instance_type = "t2.micro"
  key_name = "test01Key"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install openjdk-17-jre -y
              curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
                /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                https://pkg.jenkins.io/debian binary/ | sudo tee \
                /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt-get update -y
              sudo apt-get install jenkins -y
              EOF

  tags = {
    Name = "Jenkins-Server1"
  }
}

resource "aws_security_group" "Jenkins_SecurityGroup" {
  name        = "Jenkins_SecurityGroup"
  description = "example"
  vpc_id      = "vpc-09535705fa9d1989c"
  tags = {
    Name = "Jenkins_SecurityGroup"
  }
}

resource "aws_vpc_security_group_ingress_rule" "Jenkins_SecurityGroup_IngressRule" {
  security_group_id = aws_security_group.Jenkins_SecurityGroup.id

  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
  cidr_ipv4   = "0.0.0.0/0"
}

output "jenkins_ip" {
  value = aws_instance.jenkins.public_ip
}
