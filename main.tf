provider "aws" {
}

locals {
  naming_suffix = "ops-${var.naming_suffix}"
}

