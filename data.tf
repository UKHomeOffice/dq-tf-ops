data "aws_ami" "win" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-ops-win-bastion-448*",
    ]
  }

  owners = [
    "self",
  ]
}

data "aws_ami" "win_test" {
  most_recent = true

  filter {
    name = "name"

    values = [
      var.namespace == "prod" ? "dq-ops-win-bastion-297*" : "dq-ops-win-bastion-445*"
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
      var.namespace == "prod" ? "dq-linux-bastion 359*" : "dq-linux-bastion 375*"
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
