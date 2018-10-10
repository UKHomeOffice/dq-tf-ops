data "aws_ami" "analysis_ami" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-ops-httpd*",
    ]
  }

  owners = [
    "093401982388",
  ]
}

resource "aws_instance" "analysis" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.analysis_ami.id}"
  instance_type               = "m4.xlarge"
  iam_instance_profile        = "${aws_iam_instance_profile.httpd_server_instance_profile.id}"
  vpc_security_group_ids      = ["${aws_security_group.analysis.id}"]
  associate_public_ip_address = true
  monitoring                  = true
  private_ip                  = "${var.analysis_instance_ip}"
  subnet_id                   = "${aws_subnet.ops_public_subnet.id}"
  user_data                   = "${var.s3_bucket_name}"

  tags = {
    Name = "ec2-analysis-${local.naming_suffix}"
  }

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      "ami",
    ]
  }
}

resource "aws_security_group" "analysis" {
  vpc_id = "${aws_vpc.opsvpc.id}"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["${var.analysis_cidr_ingress}"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.management_access}",
    ]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name = "sg-analysis-${local.naming_suffix}"
  }
}

resource "aws_eip" "analysis_eip" {
  instance = "${aws_instance.analysis.id}"
  vpc      = true
}

resource "aws_route" "apps-tab" {
  route_table_id            = "${aws_route_table.ops_public_table.id}"
  destination_cidr_block    = "${var.route_table_cidr_blocks["apps_cidr"]}"
  vpc_peering_connection_id = "${var.vpc_peering_connection_ids["ops_and_apps"]}"
}

resource "aws_kms_key" "httpd_config_bucket_key" {
  description             = "This key is used to encrypt HTTPD config bucket objects"
  deletion_window_in_days = 7
}

resource "aws_s3_bucket" "httpd_config_bucket" {
  bucket = "${var.s3_bucket_name}"
  acl    = "${var.s3_bucket_acl}"
  region = "${var.region}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.httpd_config_bucket_key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${var.log_archive_s3_bucket}"
    target_prefix = "${var.service}-log/"
  }

  tags = {
    Name = "s3-${local.naming_suffix}"
  }
}

resource "aws_s3_bucket_metric" "httpd_config_bucket_logging" {
  bucket = "${var.s3_bucket_name}"
  name   = "httpd_config_bucket_metric"
}

resource "aws_iam_role_policy" "httpd_linux_iam" {
  role = "${aws_iam_role.httpd_ec2_server_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": ["s3:ListBucket"],
          "Resource": "${aws_s3_bucket.httpd_config_bucket.arn}"
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:GetObject"
          ],
          "Resource": "${aws_s3_bucket.httpd_config_bucket.arn}/*"
        },
        {
          "Effect": "Allow",
          "Action": "kms:Decrypt",
          "Resource": "${aws_kms_key.httpd_config_bucket_key.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role" "httpd_ec2_server_role" {
  name = "httpd_ec2_server_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com",
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "httpd_server_instance_profile" {
  name = "httpd_server_instance_profile"
  role = "${aws_iam_role.httpd_ec2_server_role.name}"
}

variable "s3_bucket_acl" {
  default = "private"
}

variable "region" {
  default = "eu-west-2"
}

variable "service" {
  default     = "dq-httpd-ops"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.5 document"
}

variable "analysis_instance_ip" {}

variable "analysis_cidr_ingress" {
  type = "list"

  default = [
    "62.25.109.196/32",
    "80.169.158.34/32",
    "80.193.85.91/32",
    "86.188.197.170/32",
    "86.188.197.168/32",
    "86.188.197.169/32",
    "86.188.197.171/32",
    "86.188.197.172/32",
    "86.188.197.173/32",
    "86.188.197.174/32",
    "86.188.197.175/32",
    "52.48.127.150/32",
    "52.48.127.151/32",
    "52.48.127.152/32",
    "52.48.127.153/32",
    "52.209.62.128/25",
    "52.56.62.128/25",
    "35.177.179.157/32",
    "31.221.110.80/29",
    "195.95.131.0/24",
    "5.148.69.20/32",
    "5.148.32.192/26",
    "193.164.115.0/24",
    "203.63.205.64/28",
    "5.148.32.229/32",
    "119.73.144.40/32",
    "85.211.101.55/32",
  ]
}

variable "management_access" {}

variable "s3_bucket_name" {}

output "analysis_eip" {
  value = "${aws_eip.analysis_eip.public_ip}"
}
