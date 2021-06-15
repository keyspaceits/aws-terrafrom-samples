provider "aws" {
profile = "default"
region  = "us-east-1" 
}
resource "aws_instance" "web_server" {
ami = "ami-0d5eff06f840b45e9"
instance_type = "t2.micro"
tags = { 
Name="webserver"
}
}
