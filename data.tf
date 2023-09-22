data "aws_ami" "win" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-ops-win-bastion-297*",
    ]
  }

  owners = [
    "self",
  ]
}

data "aws_ami" "win_test" {
  count = var.namespace == "prod" ? "0" : "1"

  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-ops-win-bastion-411*",
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
      "dq-linux-bastion 166*",
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
