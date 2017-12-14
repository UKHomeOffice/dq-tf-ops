module "BastionHostLinux" {
  source          = "github.com/UKHomeOffice/connectivity-tester-tf"
  user_data       = "CHECK_BDM_SSH_TCP=${var.greenplum_ip}:${var.BDM_SSH_TCP} CHECK_BDM_HTTPS_TCP=${var.BDM_HTTPS_TCP} CHECK_BDM_CUSTOM_TCP=${var.BDM_CUSTOM_TCP}"
  subnet_id       = "${aws_subnet.OPSSubnet.id}"
  security_groups = ["${aws_security_group.Bastions.id}"]
  private_ip      = "${var.bastion_linux_ip}"

  tags = {
    Name             = "ec2-${var.service}-linux-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}

module "BastionHostWindows" {
  source          = "github.com/UKHomeOffice/connectivity-tester-tf"
  user_data       = "LISTEN_http=0.0.0.0:3389 CHECK_INT_EXT_TABLEAU_RDP_TCP=${var.INT_EXT_TABLEAU_RDP_TCP} CHECK_INT_EXT_TABLEAU_HTTPS_TCP=${var.INT_EXT_TABLEAU_HTTPS_TCP} CHECK_data_pipeline_RDP_TCP=${var.data_pipeline_RDP_TCP} CHECK_data_pipeline_custom_TCP=${var.data_pipeline_custom_TCP} CHECK_data_ingest_RDP_TCP=${var.data_ingest_RDP_TCP} CHECK_data_ingest_custom_TCP=${var.data_ingest_custom_TCP}"
  subnet_id       = "${aws_subnet.OPSSubnet.id}"
  security_groups = ["${aws_security_group.Bastions.id}"]
  private_ip      = "${var.bastion_windows_ip}"

  tags = {
    Name             = "ec2-${var.service}-win-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
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
