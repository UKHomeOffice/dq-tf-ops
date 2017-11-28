resource "aws_vpc_endpoint" "S3Endpoint" {
  vpc_id       = "${aws_vpc.opsvpc.id}"
  service_name = "com.amazonaws.eu-west-2.s3"
}
