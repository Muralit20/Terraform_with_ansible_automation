variable "aws_region" {}
variable "aws_profile" {}
data "aws_availability_zones" "available" {}
variable "vpc_cidr" {}
variable "subnet_cidr" { type = "map" }
variable "rds_instance_identifier" {}
variable "database_name" {}
variable "database_user" {}
variable "database_password" {} 
variable "dev_ami" {}
variable "key_name" {}
variable "bucket_name" {}


