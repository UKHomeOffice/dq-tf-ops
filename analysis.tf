resource "aws_instance" "analysis" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.rhel_67.id}"
  instance_type               = "m4.xlarge"
  iam_instance_profile        = "${aws_iam_instance_profile.analysis.id}"
  vpc_security_group_ids      = ["${aws_security_group.analysis.id}"]
  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.ops_public_subnet.id}"

  tags = {
    Name = "ec2-analysis-${local.naming_suffix}"
  }

  lifecycle {
    prevent_destroy = false
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
      "${var.ad_sg_cidr_ingress}",
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
  instance                  = "${aws_instance.analysis.id}"
  associate_with_private_ip = "${var.analysis_instance_ip}"
  vpc                       = true
}

resource "aws_iam_role" "analysis" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "analysis" {
  role = "${aws_iam_role.analysis.name}"
}

data "aws_ami" "rhel_67" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "RHEL-6.7*",
    ]
  }

  owners = [
    "309956199498",
  ]
}

variable "analysis_instance_ip" {
  description = "Mock IP address of EC2 instance"
  default     = "10.8.2.123"
}

variable "analysis_cidr_ingress" {
  type = "list"

  default = [
    "62.25.109.196/32",
    "80.169.158.34/32",
    "80.193.85.91/32",
    "86.188.197.170/32",
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

output "analysis_eip" {
  value = "${aws_eip.analysis_eip.public_ip}"
}
