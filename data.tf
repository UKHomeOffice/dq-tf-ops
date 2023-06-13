data "aws_ami" "win" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-ops-win-bastion-288*",
    ]
  }

  owners = [
    "self",
  ]
}

data "aws_availability_zones" "available" {}

data "aws_ami" "bastion_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-linux-bastion*",
    ]
  }

  owners = [
    "self",
  ]
}

data "aws_caller_identity" "current" {}

data "aws_kms_key" "glue" {
  key_id = "alias/aws/glue"
}
