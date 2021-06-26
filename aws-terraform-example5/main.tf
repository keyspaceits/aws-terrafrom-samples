provider "aws" {
region = "ap-south-1"
profile = "default"
}
resource "aws_instance" "apec200" {
count = 1
ami = "ami-0ad704c126371a549"
instance_type = "t2.micro"
tags = {
Name = "TerraEc2"
}
}
data "aws_instance" "myec2web" {
filter {
name = "tag:Name"
values = ["TerraEc2"]
}
depends_on = [
 "aws_instance.apec200"
]
}
/* output "fetched_output"{
value = data.aws_instance.myec2web.private_ip
} */
