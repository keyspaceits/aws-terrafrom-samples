#!/bin/bash
sudo yum install httpd git -y
sudo systemctl start httpd
sudo systemctl enable httpd
sudo git clone https://github.com/keyspaceits/HealthCenter.git /var/www/html
