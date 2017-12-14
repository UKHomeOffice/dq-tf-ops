locals {
  name_prefix = "${var.name_prefix}ops-"
}

resource "aws_vpc" "opsvpc" {
  cidr_block = "${var.cidr_block}"

  tags {
    Name = "${local.name_prefix}vpc"
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

resource "aws_subnet" "ops_public_subnet" {
  vpc_id                  = "${aws_vpc.opsvpc.id}"
  cidr_block              = "${var.public_subnet_cidr_block}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.az}"

  tags {
    Name = "${local.name_prefix}public-subnet"
  }
}

resource "aws_internet_gateway" "ops_igw" {
  vpc_id = "${aws_vpc.opsvpc.id}"

  tags {
    Name = "${local.name_prefix}public-igw"
  }
}

resource "aws_eip" "ops_eip" {
  vpc = true
}

resource "aws_nat_gateway" "ops_nat_gw" {
  allocation_id = "${aws_eip.ops_eip.id}"
  subnet_id     = "${aws_subnet.ops_public_subnet.id}"
}

resource "aws_route_table" "ops_route_table" {
  vpc_id = "${aws_vpc.opsvpc.id}"

  route {
    cidr_block                = "${var.route_table_cidr_blocks["peering_cidr"]}"
    vpc_peering_connection_id = "${var.vpc_peering_connection_ids["ops_and_peering"]}"
  }

  route {
    cidr_block                = "${var.route_table_cidr_blocks["apps_cidr"]}"
    vpc_peering_connection_id = "${var.vpc_peering_connection_ids["ops_and_apps"]}"
  }

  route {
    cidr_block                = "${var.route_table_cidr_blocks["acp_vpn"]}"
    vpc_peering_connection_id = "${var.vpc_peering_connection_ids["ops_and_acpvpn"]}"
  }

  route {
    cidr_block                = "${var.route_table_cidr_blocks["acp_prod"]}"
    vpc_peering_connection_id = "${var.vpc_peering_connection_ids["ops_and_peering"]}"
  }

  route {
    cidr_block                = "${var.route_table_cidr_blocks["acp_ops"]}"
    vpc_peering_connection_id = "${var.vpc_peering_connection_ids["ops_and_peering"]}"
  }

  route {
    cidr_block                = "${var.route_table_cidr_blocks["acp_cicd"]}"
    vpc_peering_connection_id = "${var.vpc_peering_connection_ids["ops_and_peering"]}"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.ops_nat_gw.id}"
  }

  tags {
    Name = "${local.name_prefix}route-table"
  }
}

resource "aws_route_table" "ops_public_table" {
  vpc_id = "${aws_vpc.opsvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ops_igw.id}"
  }

  tags {
    Name = "${local.name_prefix}public-route-table"
  }
}

resource "aws_route_table_association" "ops_private_subnet" {
  subnet_id      = "${aws_subnet.OPSSubnet.id}"
  route_table_id = "${aws_route_table.ops_route_table.id}"
}

resource "aws_route_table_association" "ops_public_subnet" {
  subnet_id      = "${aws_subnet.ops_public_subnet.id}"
  route_table_id = "${aws_route_table.ops_public_table.id}"
}
