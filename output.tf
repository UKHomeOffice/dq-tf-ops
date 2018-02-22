output "opsvpc_id" {
  value = "${aws_vpc.opsvpc.id}"
}

output "opsvpc_cidr_block" {
  value = "${var.cidr_block}"
}

output "opssubnet_cidr_block" {
  value = "${var.vpc_subnet_cidr_block}"
}
