variable instance_type {
  default = "t2.nano"
}

data "aws_ami" "linux_connectivity_tester" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "connectivity-tester-linux*",
    ]
  }

  owners = [
    "093401982388",
  ]
}

resource "aws_instance" "BastionHostLinux" {
  ami                    = "${data.aws_ami.linux_connectivity_tester.id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${aws_subnet.OPSSubnet.id}"
  vpc_security_group_ids = ["${aws_security_group.Bastions.id}"]

  tags {
    Name = "${local.name_prefix}ec2-linux"
  }

  # user_data = "${file("${path.module}/connectivitycheck.txt")}"
}

resource "aws_instance" "BastionHostWindows" {
  ami                    = "${data.aws_ami.linux_connectivity_tester.id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${aws_subnet.OPSSubnet.id}"
  vpc_security_group_ids = ["${aws_security_group.Bastions.id}"]

  tags {
    Name = "${local.name_prefix}ec2-windows"
  }

  # user_data = "${file("${path.module}/connectivitycheck.txt")}"
}

resource "aws_security_group" "Bastions" {
  vpc_id = "${aws_vpc.opsvpc.id}"

  tags {
    Name = "${local.name_prefix}sg"
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
