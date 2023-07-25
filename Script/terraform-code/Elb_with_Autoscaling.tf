resource "aws_elb" "dev_elb" {

	subnets = ["${aws_subnet.dev_pub1_subnet.id}","${aws_subnet.dev_pub2_subnet.id}"]
	security_groups = ["${aws_security_group.dev_sg.id}"]
	listener {
		instance_port = 80
		instance_protocol = "http"
		lb_port = 80
		lb_protocol ="http"
	}
	health_check {
		healthy_threshold = "2"
		unhealthy_threshold = "2"
		timeout = "3"
		target = "TCP:80"
		interval = "30"
	}
	cross_zone_load_balancing = true
	idle_timeout = 400
	connection_draining = true
	connection_draining_timeout = 400

	tags = {
	Name = "dev_elb"
	}
}

#-------------------Golden ami --------------------
	resource "random_id" "dev_golden_ami" {
		byte_length = 3
	}

	resource "aws_ami_from_instance" "dev_ami" {
		name = "dev_ami-${random_id.dev_golden_ami.b64}"
		source_instance_id = "${aws_instance.dev_ec2.id}"
	}

#-------------Launch Configuration ---------------------

	resource "aws_launch_configuration" "dev_launch_config" {
		name = "dev_launch_config-"
		image_id = "${aws_ami_from_instance.dev_ami.id}"
		instance_type = "t2.micro"
		security_groups = ["${aws_security_group.dev_sg.id}"]
		iam_instance_profile = "${aws_iam_instance_profile.dev_profile.id}"
		key_name = "${aws_key_pair.dev_key.id}"
		lifecycle {
			create_before_destroy = true
		}
	}

#--------------Autoscaling Group ---------------

	resource "aws_autoscaling_group" "dev_asg" {
	name = "asg-${aws_launch_configuration.dev_launch_config.id}"
	max_size = "2"
	min_size = "1"
	health_check_grace_period = "300"
	health_check_type = "EC2"
	desired_capacity = "2"
	force_delete = true
	load_balancers = ["${aws_elb.dev_elb.id}"]

	vpc_zone_identifier = ["${aws_subnet.dev_pri_subnet.id}"]

	launch_configuration ="${aws_launch_configuration.dev_launch_config.name}"

		tag {
		 key = "Name"
		 value = "dev_asg_instance"
		 propagate_at_launch = true
		}

		lifecycle {
			create_before_destroy = true
		}
	}
