provider "aws" {
alias = "account1"
region = "ap-south-1"
access_key = "${var.aws1_access_key}"
secret_key = "${var.aws1_secret_key}"
}
provider "aws" {
alias = "account2"
region = "us-east-1"
access_key = "${var.aws2_access_key}"
secret_key = "${var.aws2_secret_key}"
}

/* resource "aws_vpc" "vpc-ap" {
provider = "aws.account1"
cidr_block = "172.30.0.0/16"
tags = {
Name = "vpc-ap"
}
}

resource "aws_vpc" "vpc-nv" {
provider = "aws.account2"
cidr_block = "172.31.0.0/16"
tags = {
Name = "vpc-nv"
}
} */
resource "aws_instance" "apec2" {
count = 2
provider = aws.account1
ami = "ami-0ad704c126371a549"
instance_type = "t2.micro"
tags = {
Name = "Webserver"
}
}
resource "aws_instance" "nvec2" {
provider = aws.account2
ami = "ami-0d5eff06f840b45e9"
instance_type = "t2.micro"
tags = {
Name = "Webserver"
}
}
variable "iam_users" {
default = ["sobhakanth", "nagababu", "murthy", "jyothi"]
type = list(string)
}
resource "aws_iam_user" "apiamuser"{
provider = aws.account1
count = length(var.iam_users)
name = var.iam_users[count.index]
}

/*output "apec2_pip" {
value = aws_instance.apec2.public_ip
}
output "apec2_prip" {
value = aws_instance.apec2.private_ip
}
output "apec2_subnetid" {
value = aws_instance.apec2.subnet_id
}
output "apec2_az" {
value = aws_instance.apec2[count.index].availability_zone
}
output "nvec2_pip" {
value = aws_instance.nvec2.public_ip
}
output "nvec2_prip" {
value = aws_instance.nvec2.private_ip
}
output "nvec2_subnetid" {
value = aws_instance.nvec2.subnet_id
}
output "nvec2_az" {
value = aws_instance.nvec2.availability_zone
sensitive = true
} */
