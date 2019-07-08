resource "aws_instance" "bastion_linux" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.bastion_linux.id}"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.Bastions.id}"]
  subnet_id                   = "${aws_subnet.OPSSubnet.id}"
  private_ip                  = "${var.bastion_linux_ip}"
  associate_public_ip_address = false
  monitoring                  = true

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      "user_data",
      "ami",
      "instance_type",
    ]
  }

  tags = {
    Name = "bastion-linux-${local.naming_suffix}"
  }
}

resource "aws_instance" "bastion_win" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.win.id}"
  instance_type               = "t2.large"
  vpc_security_group_ids      = ["${aws_security_group.Bastions.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ops_win.id}"
  subnet_id                   = "${aws_subnet.OPSSubnet.id}"
  private_ip                  = "${var.bastion_windows_ip}"
  associate_public_ip_address = false
  monitoring                  = true

  user_data = <<EOF
    <powershell>
    Rename-Computer -NewName "BASTION-WIN1" -Restart
    </powershell>
EOF

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      "user_data",
      "ami",
      "instance_type",
    ]
  }

  tags = {
    Name = "bastion-win-${local.naming_suffix}"
  }
}

resource "aws_instance" "bastion_win2" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.win.id}"
  instance_type               = "t2.large"
  vpc_security_group_ids      = ["${aws_security_group.Bastions.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ops_win.id}"
  subnet_id                   = "${aws_subnet.OPSSubnet.id}"
  private_ip                  = "${var.bastion2_windows_ip}"
  associate_public_ip_address = false
  monitoring                  = true

  user_data = <<EOF
	<powershell>
	Rename-Computer -NewName "BASTION-WIN2" -Restart
	</powershell>
EOF

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      "user_data",
      "ami",
      "instance_type",
    ]
  }

  tags = {
    Name = "bastion2-win-${local.naming_suffix}"
  }
}

resource "aws_instance" "bastion_win3" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.win.id}"
  instance_type               = "t2.large"
  vpc_security_group_ids      = ["${aws_security_group.Bastions.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ops_win.id}"
  subnet_id                   = "${aws_subnet.OPSSubnet.id}"
  private_ip                  = "${var.bastion3_windows_ip}"
  associate_public_ip_address = false
  monitoring                  = true

  user_data = <<EOF
	<powershell>
	Rename-Computer -NewName "BASTION-WIN3" -Restart
	</powershell>
EOF

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      "user_data",
      "ami",
      "instance_type",
    ]
  }

  tags = {
    Name = "bastion3-win-${local.naming_suffix}"
  }
}

resource "aws_instance" "bastion_win4" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.win.id}"
  instance_type               = "t2.large"
  vpc_security_group_ids      = ["${aws_security_group.Bastions.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ops_win_freight.id}"
  subnet_id                   = "${aws_subnet.OPSSubnet.id}"
  private_ip                  = "${var.bastion4_windows_ip}"
  associate_public_ip_address = false
  monitoring                  = true

  user_data = <<EOF
    <powershell>
    Rename-Computer -NewName "BASTION-WIN4" -Restart
    </powershell>
EOF

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      "user_data",
      "ami",
      "instance_type",
    ]
  }

  tags = {
    Name = "bastion4-win-${local.naming_suffix}"
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

module "ops_tableau" {
  source = "github.com/UKHomeOffice/dq-tf-ops-tableau"

  key_name                  = "${var.key_name}"
  tableau_dev_ip            = "${var.tableau_dev_ip}"
  opsvpc_id                 = "${aws_vpc.opsvpc.id}"
  tableau_subnet_cidr_block = "${var.tableau_subnet_cidr_block}"
  vpc_subnet_cidr_block     = "${var.vpc_subnet_cidr_block}"
  naming_suffix             = "${local.naming_suffix}"
  az                        = "${var.az}"
  route_table_id            = "${aws_route_table.ops_route_table.id}"
}
