#...................s3_dev_code_bucket..............
	
	resource "random_id" "dev_s3_code_bucket" {
		byte_length = 2
	}

	resource "aws_s3_bucket" "dev_s3_bucket" {
		bucket 	= "${var.bucket_name}-${random_id.dev_s3_code_bucket.dec}"
		acl	= "private"
		force_destroy	= true

		tags = {
		Name = "dev_s3_bucket"
		}
	}