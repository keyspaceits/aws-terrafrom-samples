provider "aws" {
 region = "us-east-1"
 profile = "default"
}

resource "aws_vpc" "terravpc" {
cidr_block = "172.25.0.0/16"
enable_dns_support = "true"
enable_dns_hostnames = "true"
tags = {
  Name = "terravpc"
 }
}

resource "aws_subnet" "terravpc-subnet1" {
vpc_id = aws_vpc.terravpc.id
cidr_block = "172.25.1.0/24"
availability_zone = "us-east-1a"
map_public_ip_on_launch = "true"
tags = {
  Name = "terravpc-subnet1"
 }
}

resource "aws_internet_gateway" "terraigw" {
vpc_id = aws_vpc.terravpc.id
tags = {
Name = "terraigw"
}
}

resource "aws_route_table" "rt_terravpc" {
vpc_id = aws_vpc.terravpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.terraigw.id
}
tags = {
Name = "rt_terravpc"
}
}

resource "aws_route_table_association" "rt_subnet1" {
subnet_id = aws_subnet.terravpc-subnet1.id
route_table_id = aws_route_table.rt_terravpc.id
}

resource "aws_subnet" "terravpc-subnet2" {
vpc_id = aws_vpc.terravpc.id
cidr_block = "172.25.2.0/24"
availability_zone = "us-east-1a"
map_public_ip_on_launch = "true"
tags = {
  Name = "terravpc-subnet2"
 }
}

resource "aws_eip" "eipnat" {
vpc = true
}

resource "aws_nat_gateway" "natgw" {
allocation_id = aws_eip.eipnat.id
subnet_id = aws_subnet.terravpc-subnet1.id
depends_on = [aws_internet_gateway.terraigw]
}

resource "aws_route_table" "rtPrivate_terravpc" {
vpc_id = aws_vpc.terravpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_nat_gateway.natgw.id
}
tags = {
Name = "rtPrivate_terravpc"
}
}

resource "aws_route_table_association" "rtpri_subnet2" {
subnet_id = aws_subnet.terravpc-subnet2.id
route_table_id = aws_route_table.rtPrivate_terravpc.id
}

resource "aws_security_group" "sg-tvpc" {
vpc_id = aws_vpc.terravpc.id
egress {
from_port = 0
to_port = 0
protocol = -1
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
tags = {
Name = "sg-tvpc"
}
}

resource "tls_private_key" "awssshkey" {
algorithm = "RSA"
}

resource "aws_key_pair" "sshaccesskey" {
key_name = "awssshkey"
public_key = "${tls_private_key.awssshkey.public_key_openssh}"
depends_on = [
 tls_private_key.awssshkey
]
}

resource "local_file" "key" {
content = "${tls_private_key.awssshkey.private_key_pem}"
filename = "awssshkey.pem"
file_permission = "0400"
depends_on = [
tls_private_key.awssshkey
]
}

resource "aws_instance" "web_server" {
ami = "ami-0d5eff06f840b45e9"
instance_type = "t2.micro"
subnet_id = aws_subnet.terravpc-subnet1.id
key_name = "${aws_key_pair.sshaccesskey.key_name}"
vpc_security_group_ids = ["${aws_security_group.sg-tvpc.id}"]
user_data = "${file("webserver.sh")}"

tags = {
Name="webserver"
}
}

resource "aws_instance" "web_server2" {
ami = "ami-0d5eff06f840b45e9"
instance_type = "t2.micro"
subnet_id = aws_subnet.terravpc-subnet1.id
key_name = "${aws_key_pair.sshaccesskey.key_name}"
vpc_security_group_ids = ["${aws_security_group.sg-tvpc.id}"]

provisioner "file" {
source = "appserver.sh"
destination = "/home/ec2-user/appserver.sh"
connection {
type     = "ssh"
user = "ec2-user"
host = "${self.public_ip}"
private_key = "${file("awssshkey.pem")}"
#private_key = "${aws_key_pair.sshaccesskey.key_name}"
}
}
provisioner "remote-exec" {
inline = [ 
"chmod +x /home/ec2-user/appserver.sh",
"sudo /bin/bash /home/ec2-user/appserver.sh"
]
connection {
type     = "ssh"
user = "ec2-user"
host = "${self.public_ip}"
private_key = "${file("awssshkey.pem")}"
#private_key = "${aws_key_pair.sshaccesskey.key_name}"
}
}
tags = {
Name = "Webserver2"
}
}
resource "aws_instance" "web_server3" {
ami = "ami-0d5eff06f840b45e9"
instance_type = "t2.micro"
subnet_id = aws_subnet.terravpc-subnet1.id
key_name = "${aws_key_pair.sshaccesskey.key_name}"
vpc_security_group_ids = ["${aws_security_group.sg-tvpc.id}"]

provisioner "file" {
source = "appserver.sh"
destination = "/home/ec2-user/appserver.sh"
connection {
type     = "ssh"
user = "ec2-user"
host = "${self.public_ip}"
#private_key = "${file("awssshkey.pem")}"
#private_key = "${aws_key_pair.sshaccesskey.key_name}.pem"
private_key = "${file("${aws_key_pair.sshaccesskey.key_name}.pem")}"
}
}
provisioner "remote-exec" {
inline = [ 
"chmod +x /home/ec2-user/appserver.sh",
"sudo /bin/bash /home/ec2-user/appserver.sh"
]
connection {
type     = "ssh"
user = "ec2-user"
host = "${self.public_ip}"
#private_key = "${file("awssshkey.pem")}"
private_key = "${file("${aws_key_pair.sshaccesskey.key_name}.pem")}"
}
}
tags = {
Name = "Webserver3"
}
}
