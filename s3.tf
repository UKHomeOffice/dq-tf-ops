resource "aws_vpc_endpoint" "log_archive" {
  vpc_id          = "${aws_vpc.opsvpc.id}"
  route_table_ids = ["${aws_route_table.ops_route_table.id}"]
  service_name    = "com.amazonaws.eu-west-2.s3"
}
