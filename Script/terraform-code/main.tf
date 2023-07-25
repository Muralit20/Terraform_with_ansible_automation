provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

######----------RDS---------#######

  resource "aws_db_instance" "dev_db" {
  identifier                = "${var.rds_instance_identifier}"
  allocated_storage         = 10
  engine                    = "mysql"
  engine_version            = "5.6.35"
  instance_class            = "db.t2.micro"
  name                      = "${var.database_name}"
  username                  = "${var.database_user}"
  password                  = "${var.database_password}"
  db_subnet_group_name      = "${aws_db_subnet_group.dev_rds_sub_grp.name}"
  vpc_security_group_ids    = ["${aws_security_group.dev_sg.id}"]
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
}

resource "aws_key_pair" "dev_key" {
        key_name = "${var.key_name}"
        public_key = "${file("Master.pub")}"
}

######----------EC2---------#######
resource "aws_instance" "dev_ec2" {
   ami  = "${var.dev_ami}"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.dev_key.id}"
   subnet_id = "${aws_subnet.dev_pub1_subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.dev_sg.id}"]
   iam_instance_profile = "${aws_iam_instance_profile.dev_profile.id}"
   associate_public_ip_address = true
   source_dest_check = false
    user_data = "${file("ansible_user.sh")}"
   provisioner "local-exec" {
   command = <<EOD
   cat <<EOF > hosts
   [prod]
   ${aws_instance.dev_ec2.public_ip}
   [prod:vars]
   ansible_connection_port=ssh
   ansible_ssh_user=ansible
   ansible_ssh_pass=admin
   s3code=${aws_s3_bucket.dev_s3_bucket.bucket}
   rdsendpoint=${aws_db_instance.dev_db.endpoint}
   EOF
   EOD
   }
   provisioner "local-exec" {
        command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.dev_ec2.id} --profile devops"
   }
   provisioner "local-exec" {
        command = "ansible-playbook -i hosts wordpress.yml"
   }


  tags = {
    Name = "dev"
  }
}
terraform {
  backend "s3" {
    bucket = "devopsterraformbackup"
    key = ".terraform/terraform.tfstate"
    dynamodb_table = "terraform-lock"
    region = "ap-southeast-1"
  }
}
