resource "aws_security_group" "dev_sg" {
  vpc_id = "${aws_vpc.dev_vpc.id}"
  name = "test"
  ingress {
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks	  = ["10.0.0.0/16"]
  }
  ingress {
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks	  = ["0.0.0.0/0"]
  }
  ingress {
    from_port     = 80
    to_port       = 80
    protocol      = "tcp"
    cidr_blocks	  = ["0.0.0.0/0"]
  }
  ingress {
    from_port     = 443
    to_port       = 443
    protocol      = "tcp"
    cidr_blocks	  = ["0.0.0.0/0"]
  }
  ingress {
    from_port     = 3306
    to_port       = 3306
    protocol      = "tcp"
    cidr_blocks	  = ["10.0.0.0/16"]
  }
  ingress {
    from_port     = 3306
    to_port       = 3306
    protocol      = "tcp"
    cidr_blocks	  = ["10.0.0.0/16"]
  }
  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks	  = ["0.0.0.0/0"]
  }

}