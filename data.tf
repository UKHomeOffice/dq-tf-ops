data "aws_ami" "win" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-ops-win-*",
    ]
  }

  owners = [
    "093401982388",
  ]
}

data "aws_availability_zones" "available" {}

data "aws_ami" "rhel" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "RHEL-7.4*",
    ]
  }

  owners = [
    "309956199498",
  ]
}

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
