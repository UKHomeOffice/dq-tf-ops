/*********************************
* Create EC2 instance
**********************************/
# Instance in OPS Subnet in AZ1
resource "aws_instance" "BastionHostWindows" {
 ami           = "${var.bastion_win_ami_id}"
 instance_type = "${var.instance_class}"
 key_name = "${var.opskey}"
 subnet_id = "${aws_subnet.OPSSubnet.id}"
 vpc_security_group_ids = ["${aws_security_group.BastionWindowsSG.id}"]

 tags {
   Name = "BastionWindows"
 }
}

# Instance in OPS Subnet AZ1
resource "aws_instance" "BastionHostLinux" {
 ami           = "${var.bastion_linux_ami_id}"
 instance_type = "${var.instance_class}"
 key_name = "${var.opskey}"
 subnet_id = "${aws_subnet.OPSSubnet.id}"
 vpc_security_group_ids = ["${aws_security_group.BastionLinuxSG.id}"]

 tags {
   Name = "BastionLinux"
 }
}

/*********************************
 * Security group.
**********************************/
resource "aws_security_group" "BastionWindowsSG" {
  description = "Default security group for all instances Windows instances"
  vpc_id      = "${aws_vpc.opsvpc.id}"
  tags {
    Name = "Bastion Windows SG"
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
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

resource "aws_security_group" "BastionLinuxSG" {
  description = "Default security group for all instances Linux instances"
  vpc_id      = "${aws_vpc.opsvpc.id}"
  tags {
    Name = "Bastion Linux SG"
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
