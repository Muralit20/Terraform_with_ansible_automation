#........VPC.............

    resource "aws_vpc" "dev_vpc" {
      cidr_block           = "${var.vpc_cidr}"
      enable_dns_hostnames = true
      enable_dns_support   = true
      tags = {
        Name = "dev_vpc"
      }
    }

#........IG.............

      resource "aws_internet_gateway" "dev_igw" {
        vpc_id = "${aws_vpc.dev_vpc.id}"

        tags = {
          Name = "dev_igw"
        }
      }

#-----------Route-table----------

  #--Public------

    resource "aws_route_table" "dev_pub_route" {
      vpc_id = "${aws_vpc.dev_vpc.id}"
      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.dev_igw.id}"
      }
      tags = {
        Name = "dev_pub_route"
      }
    }

  #--Public-Routable-Association----------------
      
    resource "aws_route_table_association" "ra_pub_01" {
      subnet_id      = "${aws_subnet.dev_pub1_subnet.id}"
      route_table_id = "${aws_route_table.dev_pub_route.id}"
    }
    resource "aws_route_table_association" "ra_pub_02" {
      subnet_id      = "${aws_subnet.dev_pub2_subnet.id}"
      route_table_id = "${aws_route_table.dev_pub_route.id}"
    }

    resource "aws_route_table_association" "ra_pub_03" {
      subnet_id      = "${aws_subnet.dev_rds1_subnet.id}"
      route_table_id = "${aws_route_table.dev_pub_route.id}"
    }

  #--Private------

    resource "aws_route_table" "dev_pri_route" {
      vpc_id = "${aws_vpc.dev_vpc.id}"
      tags = {
        Name = "dev_pri_route"
      }
    }

  #--Private-Routable-Association----------------

    resource "aws_route_table_association" "ra_pri1" {
      subnet_id      = "${aws_subnet.dev_pri_subnet.id}"
      route_table_id = "${aws_route_table.dev_pri_route.id}"
    }
    resource "aws_route_table_association" "ra_pri2" {
      subnet_id      = "${aws_subnet.dev_rds2_subnet.id}"
      route_table_id = "${aws_route_table.dev_pri_route.id}"
    }

#-----------Subnets----------
  #---Public------

    resource "aws_subnet" "dev_pub1_subnet" {
      vpc_id                  = "${aws_vpc.dev_vpc.id}"
      cidr_block              = "${var.subnet_cidr["public1"]}"
      map_public_ip_on_launch = true
      availability_zone       = "${data.aws_availability_zones.available.names[0]}"
      tags = {
        Name = "dev_pub_subnet"
      }
    }

     resource "aws_subnet" "dev_pub2_subnet" {
      vpc_id                  = "${aws_vpc.dev_vpc.id}"
      cidr_block              = "${var.subnet_cidr["public2"]}"
      map_public_ip_on_launch = true
      availability_zone       = "${data.aws_availability_zones.available.names[1]}"
      tags = {
        Name = "dev_pub_subnet"
      }
    }

  #---Private------

      resource "aws_subnet" "dev_pri_subnet" {
        vpc_id                  = "${aws_vpc.dev_vpc.id}"
        cidr_block              = "${var.subnet_cidr["private"]}"
        map_public_ip_on_launch = false
        availability_zone       = "${data.aws_availability_zones.available.names[0]}"
        tags = {
          Name = "dev_pri_subnet"
        }
      }

  #---RDS-Subnet-1------

    resource "aws_subnet" "dev_rds1_subnet" {
      vpc_id                  = "${aws_vpc.dev_vpc.id}"
      cidr_block              = "${var.subnet_cidr["rds1"]}"
      map_public_ip_on_launch = false
      availability_zone       = "${data.aws_availability_zones.available.names[0]}"
      tags = {
        Name = "dev_rds1_subnet"
      }
    }

  #---RDS-Subnet-2------

    resource "aws_subnet" "dev_rds2_subnet" {
      vpc_id                  = "${aws_vpc.dev_vpc.id}"
      cidr_block              = "${var.subnet_cidr["rds2"]}"
      map_public_ip_on_launch = false
      availability_zone       = "${data.aws_availability_zones.available.names[1]}"
      tags = {
        Name = "dev_rds2_subnet"
      }
    }

  #-----RDS-Subnet-Group-----------

    resource "aws_db_subnet_group" "dev_rds_sub_grp" {
      name       = "dev_rds_sub_grp"
      subnet_ids = ["${aws_subnet.dev_rds1_subnet.id}", "${aws_subnet.dev_rds2_subnet.id}"]
      tags = {
        Name = "dev_rds_sub_grp"
      }
    }
#-------------Endpoint----------------
resource "aws_vpc_endpoint" "dev_private-s3_endpoint" {
  vpc_id       = "${aws_vpc.dev_vpc.id}"
  service_name = "com.amazonaws.${var.aws_region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  vpc_endpoint_id = "${aws_vpc_endpoint.dev_private-s3_endpoint.id}"
  route_table_id  = "${aws_route_table.dev_pri_route.id}"
}