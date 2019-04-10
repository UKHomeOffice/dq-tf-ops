provider "aws" {}

locals {
  naming_suffix = "ops-${var.naming_suffix}"
}

module "ops-tableau" {
  source = "github.com/UKHomeOffice/dq-tf-ops-tableau"

  key_name                  = "${var.key_name}"
  tableau_dev_ip            = "${var.tableau_dev_ip}"
  opsvpc_id                 = "${aws_vpc.opsvpc.id}"
  tableau_subnet_cidr_block = "${var.tableau_subnet_cidr_block}"
  vpc_subnet_cidr_block     = "${var.tableau_vpc_subnet_cidr_block}"
  naming_suffix             = "${local.naming_suffix}"
  az                        = "${var.az}"
  route_table_id            = "${var.tableau_route_table_id}"
}
