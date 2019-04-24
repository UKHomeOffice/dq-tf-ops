output "opsvpc_id" {
  value = "${aws_vpc.opsvpc.id}"
}

output "opsvpc_cidr_block" {
  value = "${var.cidr_block}"
}

output "opssubnet_cidr_block" {
  value = "${var.vpc_subnet_cidr_block}"
}

output "ad_subnet_id" {
  value = "${aws_subnet.ad_subnet.id}"
}

output "iam_roles" {
  value = [
    "${aws_iam_role.ops_win.id}",
    "${aws_iam_role.httpd_ec2_server_role.id}",
  ]
}

output "httpd_config_bucket_key" {
  value = "${aws_kms_key.httpd_config_bucket_key.arn}"
}

output "httpd_config_bucket" {
  value = "${aws_s3_bucket.httpd_config_bucket.id}"
}
