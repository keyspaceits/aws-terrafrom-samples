variable "region" {
/*default = "us-east-1"
type = string
description = "region for my vpc1"*/
}

variable "vpc1_cidr" {
/*default = "172.20.0.0/16"
type = string
description = "cidr block for my vpc1"*/
}
variable "private_subnets" {
/*default = ["172.20.1.0/24","172.20.3.0/24","172.20.5.0/24"]
type = list
description = "cidr for private subnets"*/
}
variable "public_subnets" {
/*default = ["172.20.0.0/24", "172.20.2.0/24","172.20.4.0/24"]
type = list
description = "list of subnets cidr blocks"*/
}

variable "az_list" {
/*default = ["us-east-1a", "us-east-1b", "us-east-1c"]
type = list 
description = "az list"*/
}
