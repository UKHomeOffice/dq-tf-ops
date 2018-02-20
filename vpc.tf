resource "aws_vpc" "opsvpc" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "vpc-${local.naming_suffix}"
  }
}

resource "aws_subnet" "OPSSubnet" {
  vpc_id                  = "${aws_vpc.opsvpc.id}"
  cidr_block              = "${var.vpc_subnet_cidr_block}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.az}"

  tags {
    Name = "subnet-${local.naming_suffix}"
  }
}

resource "aws_subnet" "ops_public_subnet" {
  vpc_id                  = "${aws_vpc.opsvpc.id}"
  cidr_block              = "${var.public_subnet_cidr_block}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.az}"

  tags {
    Name = "public-subnet-${local.naming_suffix}"
  }
}

resource "aws_internet_gateway" "ops_igw" {
  vpc_id = "${aws_vpc.opsvpc.id}"

  tags {
    Name = "public-igw-${local.naming_suffix}"
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

  tags {
    Name = "route-table-${local.naming_suffix}"
  }
}

resource "aws_route" "peering" {
  route_table_id            = "${aws_route_table.ops_route_table.id}"
  destination_cidr_block    = "${var.route_table_cidr_blocks["peering_cidr"]}"
  vpc_peering_connection_id = "${var.vpc_peering_connection_ids["ops_and_peering"]}"
}

resource "aws_route" "apps" {
  route_table_id            = "${aws_route_table.ops_route_table.id}"
  destination_cidr_block    = "${var.route_table_cidr_blocks["apps_cidr"]}"
  vpc_peering_connection_id = "${var.vpc_peering_connection_ids["ops_and_apps"]}"
}

resource "aws_route" "acp_vpn" {
  route_table_id            = "${aws_route_table.ops_route_table.id}"
  destination_cidr_block    = "${var.route_table_cidr_blocks["acp_vpn"]}"
  vpc_peering_connection_id = "${var.vpc_peering_connection_ids["ops_and_acpvpn"]}"
}

resource "aws_route" "nat" {
  route_table_id         = "${aws_route_table.ops_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.ops_nat_gw.id}"
}

resource "aws_route_table" "ops_public_table" {
  vpc_id = "${aws_vpc.opsvpc.id}"

  tags {
    Name = "public-route-table-${local.naming_suffix}"
  }
}

resource "aws_route" "igw" {
  route_table_id         = "${aws_route_table.ops_public_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ops_igw.id}"
}

resource "aws_route_table_association" "ops_private_subnet" {
  subnet_id      = "${aws_subnet.OPSSubnet.id}"
  route_table_id = "${aws_route_table.ops_route_table.id}"
}

resource "aws_route_table_association" "ops_public_subnet" {
  subnet_id      = "${aws_subnet.ops_public_subnet.id}"
  route_table_id = "${aws_route_table.ops_public_table.id}"
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.opsvpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
