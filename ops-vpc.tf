/*********************************
 * VPC.
 * Virtual network which will be referred to as "opsvpc" in this example.
**********************************/
resource "aws_vpc" "opsvpc" {
  cidr_block = "${var.opsvpc}"
  tags {
    Name = "OPS VPC"
  }
}

/*********************************
* IGW endpoint
**********************************/

resource "aws_internet_gateway" "OpsRouteToInternet" {
  vpc_id = "${aws_vpc.opsvpc.id}"
  tags {
    Name = "OPS IGW"
  }
}

/*********************************
 * Subnet no.1
 * Availability zone no.1
**********************************/

resource "aws_subnet" "OPSSubnet" {
  vpc_id                  = "${aws_vpc.opsvpc.id}"
  cidr_block              = "${var.OPSSubnet-cidr-block}"
  map_public_ip_on_launch = true
  availability_zone       = "${var.AZ1}"
  tags {
    Name = "OPS subnet"
  }
}

/*********************************
* Create route table
**********************************/

resource "aws_route_table" "OPSVPCMainRouteTable" {
  vpc_id = "${aws_vpc.opsvpc.id}"
  tags {
  Name = "OPSVPCMainRouteTable"
  }

  route {
  cidr_block = "${var.opsvpc-internet_access}"
  gateway_id = "${aws_internet_gateway.OpsRouteToInternet.id}"
  }

  route {
  cidr_block = "${var.peeringvpc}"
  vpc_peering_connection_id = "${var.opsvpc_vpc_peering_id}"
  }

  route {
  cidr_block = "${var.prodvpc}"
  vpc_peering_connection_id = "${var.opsvpc_vpc_peering_id}"
  }

  route {
  cidr_block = "${var.apcprodvpc}"
  vpc_peering_connection_id = "${var.opsvpc_vpc_peering_id}"
  }

  route {
  cidr_block = "${var.apccicdvpc}"
  vpc_peering_connection_id = "${var.opsvpc_vpc_peering_id}"
  }

  route {
  cidr_block = "${var.apcopsvpc}"
  vpc_peering_connection_id = "${var.opsvpc_vpc_peering_id}"
  }
}

/*********************************
* Route Table association
**********************************/

resource "aws_route_table_association" "OPSInstances" {
  subnet_id      = "${aws_subnet.OPSSubnet.id}"
  route_table_id = "${aws_route_table.OPSVPCMainRouteTable.id}"
}

/*********************************
* Access lists
**********************************/

# Disable default ACL
resource "aws_default_network_acl" "default" {
  default_network_acl_id = "${aws_vpc.opsvpc.default_network_acl_id}"
  tags {
  Name = "Default VPC ACL"
  }
}

resource "aws_network_acl" "OPSACL" {
  vpc_id = "${aws_vpc.opsvpc.id}"
  subnet_ids = ["${aws_subnet.OPSSubnet.id}"]

ingress {
  protocol   = "-1"
  rule_no    = 100
  action     = "allow"
  cidr_block  = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
}

egress {
  protocol   = "-1"
  rule_no    = 200
  action     = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
}
  tags {
    Name = "OPS ACL"
    }
  }
