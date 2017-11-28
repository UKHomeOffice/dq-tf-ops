variable "cidr_block" {}
variable "vpc_subnet_cidr_block" {}
variable "az" {}
variable "name_prefix" {}

locals {
  name_prefix = "${var.name_prefix}ops-"
}

resource "aws_vpc" "opsvpc" {
  cidr_block = "${var.cidr_block}"

  tags {
    Name = "${local.name_prefix}VPC"
  }
}

resource "aws_internet_gateway" "OpsRouteToInternet" {
  vpc_id = "${aws_vpc.opsvpc.id}"

  tags {
    Name = "${local.name_prefix}IGW"
  }
}

resource "aws_subnet" "OPSSubnet" {
  vpc_id                  = "${aws_vpc.opsvpc.id}"
  cidr_block              = "${var.vpc_subnet_cidr_block}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.az}"

  tags {
    Name = "${local.name_prefix}subnet"
  }
}
