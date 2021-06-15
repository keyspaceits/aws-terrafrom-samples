provider "aws" {
region = "${var.region}"
profile = "default"
}
resource "aws_vpc" "vpc1" {
cidr_block = "${var.vpc1_cidr}"
enable_dns_hostnames = true
enable_dns_support = true
tags = {
Name = "vpc1"
}
}
resource "aws_subnet" "private_subnets" {
count = length(var.private_subnets)
vpc_id = aws_vpc.vpc1.id
cidr_block = var.private_subnets[count.index]
map_public_ip_on_launch = "true"
availability_zone = var.az_list[count.index]
tags = {
Name = "private-subnet"
}
}
resource "aws_subnet" "public_subnets" {
count = length(var.public_subnets)
vpc_id = aws_vpc.vpc1.id
cidr_block = var.public_subnets[count.index]
availability_zone = var.az_list[count.index]
map_public_ip_on_launch = "true"
tags = {
Name = "public-subnet"
}
}
resource "aws_internet_gateway" "vpc1-igw" {
vpc_id = aws_vpc.vpc1.id
}
resource "aws_route_table" "public" {
vpc_id = aws_vpc.vpc1.id
tags = {
Name = "PublicRT"
}
}

resource "aws_route_table" "private" {
vpc_id = aws_vpc.vpc1.id
tags = {
Name = "PrivateRT"
}
}

resource "aws_route" "public" {
route_table_id = aws_route_table.public.id
destination_cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.vpc1-igw.id
}
resource "aws_route_table_association" "public" {
count = length(var.public_subnets)
subnet_id = aws_subnet.public_subnets[count.index].id
route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
count = length(var.private_subnets)
subnet_id = aws_subnet.private_subnets[count.index].id
route_table_id = aws_route_table.private.id
}
