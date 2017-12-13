variable "cidr_block" {}
variable "vpc_subnet_cidr_block" {}
variable "az" {}
variable "name_prefix" {}

variable "route_table_cidr_blocks" {
  description = "Map of CIDR blocks for the OPs private route table."
  type        = "map"

  default = {
    name = false
  }
}

variable "vpc_peering_to_peering_id" {
  default     = false
  description = "VPC peering to peering id"
}

variable "peering_to_acpvpn_id" {
  default     = false
  description = "Peering to ACP vpn idg"
}

variable "greenplum_ip" {
  default     = false
  description = "IP address for Greenplum"
}

variable "bastion_linux_ip" {
  description = "Mock EC2 instance IP"
  default     = "10.2.0.11"
}

variable "bastion_windows_ip" {
  description = "Mock EC2 instance IP"
  default     = "10.2.0.12"
}

variable "service" {
  default     = "dq-bastion-host"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.5 document"
}

variable "environment" {
  default     = "preprod"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.5 document"
}

variable "environment_group" {
  default     = "dq-ops"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.5 document"
}

variable "BDM_HTTPS_TCP" {
  default     = false
  description = "HTTPS TCP connectivty port for business data manager app"
}

variable "BDM_SSH_TCP" {
  default     = false
  description = "SSH TCP connectivty port for business data manager app"
}

variable "BDM_CUSTOM_TCP" {
  default     = false
  description = "BDM Custom TCP connectivty port for business data manager app"
}
