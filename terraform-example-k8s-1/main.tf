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

resource "aws_route_table_association" "rtpri_subnet2" {
subnet_id = aws_subnet.terravpc-subnet2.id
route_table_id = aws_route_table.rt_terravpc.id
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
from_port = 1
to_port = 65535
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
tags = {
Name = "sg-tvpc"
}
}

resource "aws_instance" "web_server" {
ami = "ami-09e67e426f25ce0d7"
instance_type = "t2.medium"
subnet_id = aws_subnet.terravpc-subnet1.id
key_name = "k8s"
vpc_security_group_ids = ["${aws_security_group.sg-tvpc.id}"]
provisioner "file" {
source = "masternode.sh"
destination = "/home/ubuntu/masternode.sh"
connection {
type     = "ssh"
user = "ubuntu"
host = "${self.public_ip}"
private_key = "${file("k8s.pem")}"
#private_key = "${aws_key_pair.sshaccesskey.key_name}"
#private_key = "${file("${aws_key_pair.s.key_name}.pem")}"
}
}
provisioner "remote-exec" {
inline = [ 
"sudo chmod +x /home/ubuntu/masternode.sh",
"sudo /bin/bash /home/ubuntu/masternode.sh"
]
connection {
type     = "ssh"
user = "ubuntu"
host = "${self.public_ip}"
private_key = "${file("k8s.pem")}"
#private_key = "${aws_key_pair.sshaccesskey.key_name}"
#private_key = "${file("${aws_key_pair.sshaccesskey.key_name}.pem")}"
}
}
tags = {
Name="webserver"
}
}
resource "aws_eip" "eipmaster" {
  vpc = true
  instance                  = "${aws_instance.web_server.id}"
 # associate_with_private_ip = "${aws_instance.web_server.private_ip}"
  depends_on                = [aws_internet_gateway.terraigw]
}

resource "aws_instance" "web_server2" {
ami = "ami-09e67e426f25ce0d7"
instance_type = "t2.medium"
subnet_id = aws_subnet.terravpc-subnet1.id
key_name = "k8s"
vpc_security_group_ids = ["${aws_security_group.sg-tvpc.id}"]

provisioner "file" {
source = "k8s/"
destination = "/home/ubuntu/"
connection {
type     = "ssh"
user = "ubuntu"
host = "${self.public_ip}"
private_key = "${file("k8s.pem")}"
#private_key = "${aws_key_pair.sshaccesskey.key_name}"
#private_key = "${file("${aws_key_pair.s.key_name}.pem")}"
}
}
provisioner "remote-exec" {
inline = [ 
"chmod +x /home/ubuntu/workernode.sh",
"sudo /bin/bash /home/ubuntu/workernode.sh",
"sudo chmod 600 /home/ubuntu/k8s.pem",
"sudo scp -i k8s.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${aws_eip.eipmaster.public_ip}:~/token.sh ~ubuntu/",
"sudo chmod u+x ~ubuntu/token.sh",
"sudo /bin/bash /home/ubuntu/token.sh"
]
connection {
type     = "ssh"
user = "ubuntu"
host = "${self.public_ip}"
private_key = "${file("k8s.pem")}"
#private_key = "${aws_key_pair.sshaccesskey.key_name}"
#private_key = "${file("${aws_key_pair.sshaccesskey.key_name}.pem")}"
}
}
tags = {
Name = "K8s-WorkerNode1"
}
}
resource "aws_instance" "web_server3" {
ami = "ami-09e67e426f25ce0d7"
instance_type = "t2.medium"
subnet_id = aws_subnet.terravpc-subnet1.id
key_name = "k8s"
vpc_security_group_ids = ["${aws_security_group.sg-tvpc.id}"]

provisioner "file" {
source = "k8s/"
destination = "/home/ubuntu/"
connection {
type     = "ssh"
user = "ubuntu"
host = "${self.public_ip}"
private_key = "${file("k8s.pem")}"
#private_key = "${aws_key_pair.sshaccesskey.key_name}"
#private_key = "${file("${aws_key_pair.s.key_name}.pem")}"
}
}
provisioner "remote-exec" {
inline = [ 
"chmod +x /home/ubuntu/workernode2.sh",
"sudo /bin/bash /home/ubuntu/workernode2.sh",
"sudo chmod 600 /home/ubuntu/k8s.pem",
"sudo scp -i k8s.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${aws_eip.eipmaster.public_ip}:~/token.sh ~ubuntu/",
"sudo chmod u+x ~ubuntu/token.sh",
"sudo /bin/bash /home/ubuntu/token.sh"
]
connection {
type     = "ssh"
user = "ubuntu"
host = "${self.public_ip}"
private_key = "${file("k8s.pem")}"
#private_key = "${aws_key_pair.sshaccesskey.key_name}"
#private_key = "${file("${aws_key_pair.sshaccesskey.key_name}.pem")}"
}
}
tags = {
Name = "K8s-WorkerNode2"
}
}
