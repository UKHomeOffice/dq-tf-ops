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
    [Environment]::SetEnvironmentVariable("S3_OPS_CONFIG_BUCKET", "${var.ops_config_bucket}/sqlworkbench", "Machine")
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
  [Environment]::SetEnvironmentVariable("S3_OPS_CONFIG_BUCKET", "${var.ops_config_bucket}/sqlworkbench", "Machine")
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
  [Environment]::SetEnvironmentVariable("S3_OPS_CONFIG_BUCKET", "${var.ops_config_bucket}/sqlworkbench", "Machine")
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
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.Bastions.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ops_win_freight.id}"
  subnet_id                   = "${aws_subnet.OPSSubnet.id}"
  private_ip                  = "${var.bastion4_windows_ip}"
  associate_public_ip_address = false
  monitoring                  = true

  user_data = <<EOF
    <powershell>
    Rename-Computer -NewName "BASTION-WIN4" -Restart
    [Environment]::SetEnvironmentVariable("S3_OPS_CONFIG_BUCKET", "${var.ops_config_bucket}/sqlworkbench", "Machine")
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

resource "aws_instance" "bastion_win5" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.win.id}"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.Bastions.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ops_win_freight.id}"
  subnet_id                   = "${aws_subnet.OPSSubnet.id}"
  private_ip                  = "${var.bastion5_windows_ip}"
  associate_public_ip_address = false
  monitoring                  = true

  user_data = <<EOF
    <powershell>
    Rename-Computer -NewName "BASTION-WIN5" -Restart
    [Environment]::SetEnvironmentVariable("S3_OPS_CONFIG_BUCKET", "${var.ops_config_bucket}/sqlworkbench", "Machine")
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
    Name = "bastion5-win-${local.naming_suffix}"
  }
}

resource "aws_instance" "bastion_win6" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.win.id}"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.Bastions.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ops_win_freight.id}"
  subnet_id                   = "${aws_subnet.OPSSubnet.id}"
  private_ip                  = "${var.bastion6_windows_ip}"
  associate_public_ip_address = false
  monitoring                  = true

  user_data = <<EOF
    <powershell>
    Rename-Computer -NewName "BASTION-WIN6" -Restart
    [Environment]::SetEnvironmentVariable("S3_OPS_CONFIG_BUCKET", "${var.ops_config_bucket}/sqlworkbench", "Machine")
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
    Name = "bastion6-win-${local.naming_suffix}"
  }
}

resource "aws_instance" "bastion_win7" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.win.id}"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.Bastions.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ops_win_freight.id}"
  subnet_id                   = "${aws_subnet.OPSSubnet.id}"
  private_ip                  = "${var.bastion7_windows_ip}"
  associate_public_ip_address = false
  monitoring                  = true

  user_data = <<EOF
    <powershell>
    Rename-Computer -NewName "BASTION-WIN7" -Restart
    [Environment]::SetEnvironmentVariable("S3_OPS_CONFIG_BUCKET", "${var.ops_config_bucket}/sqlworkbench", "Machine")
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
    Name = "bastion7-win-${local.naming_suffix}"
  }
}

resource "aws_instance" "bastion_win8" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.win.id}"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.Bastions.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ops_win_freight.id}"
  subnet_id                   = "${aws_subnet.OPSSubnet.id}"
  private_ip                  = "${var.bastion8_windows_ip}"
  associate_public_ip_address = false
  monitoring                  = true

  user_data = <<EOF
    <powershell>
    Rename-Computer -NewName "BASTION-WIN8" -Restart
    [Environment]::SetEnvironmentVariable("S3_OPS_CONFIG_BUCKET", "${var.ops_config_bucket}/sqlworkbench", "Machine")
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
    Name = "bastion8-win-${local.naming_suffix}"
  }
}

resource "aws_volume_attachment" "nfs_attachment" {
  device_name = "xvdf"
  volume_id   = "${aws_ebs_volume.nfs_volume.id}"
  instance_id = "${aws_instance.nfs_server.id}"
}

resource "aws_instance" "nfs_server" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.win_nfs.id}"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.Bastions.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ops_win_freight.id}"
  subnet_id                   = "${aws_subnet.OPSSubnet.id}"
  private_ip                  = "${var.nfs_windows_ip}"
  associate_public_ip_address = false
  monitoring                  = true

  user_data = <<EOF
    <powershell>
    Rename-Computer -NewName "NFS-SERVER" -Restart
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
    Name = "nfs-server-win-${local.naming_suffix}"
  }
}

resource "aws_ebs_volume" "nfs_volume" {
  availability_zone = "eu-west-2a"
  size              = 10
  encrypted         = true
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
