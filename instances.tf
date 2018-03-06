resource "aws_instance" "bastion_linux" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.bastion_linux.id}"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.Bastions.id}"]
  subnet_id                   = "${aws_subnet.OPSSubnet.id}"
  private_ip                  = "${var.bastion_linux_ip}"
  associate_public_ip_address = false

  tags = {
    Name = "bastion-linux-${local.naming_suffix}"
  }
}

resource "aws_instance" "bastion_win" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.win.id}"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.Bastions.id}"]
  subnet_id                   = "${aws_subnet.OPSSubnet.id}"
  private_ip                  = "${var.bastion_windows_ip}"
  associate_public_ip_address = false

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      "ami_name",
    ]
  }

  tags = {
    Name = "bastion-win-${local.naming_suffix}"
  }
}

resource "aws_ssm_association" "bastion_win" {
  name        = "${var.ad_aws_ssm_document_name}"
  instance_id = "${aws_instance.bastion_win.id}"
}

resource "aws_security_group" "Bastions" {
  vpc_id = "${aws_vpc.opsvpc.id}"

  tags {
    Name = "sg-bastions-${local.naming_suffix}"
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
