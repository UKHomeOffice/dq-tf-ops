variable "cidr_block" {}
variable "vpc_subnet_cidr_block" {}
variable "az" {}
variable "name_prefix" {}

variable "vpc_peering_connection_ids" {
  description = "Map of VPC peering IDs for the Ops route table."
  type        = "map"
}

variable "route_table_cidr_blocks" {
  description = "Map of CIDR blocks for the OPs private route table."
  type        = "map"
}

variable "greenplum_ip" {
  default     = false
  description = "IP address for Greenplum"
}

variable "bastion_linux_ip" {
  description = "Mock EC2 instance IP"
}

variable "bastion_windows_ip" {
  description = "Mock EC2 instance IP"
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

variable "INT_EXT_TABLEAU_RDP_TCP" {
  default     = false
  description = "RDP TCP connectivty port for external and internal tableau apps"
}

variable "INT_EXT_TABLEAU_HTTPS_TCP" {
  default     = false
  description = "HTTPS TCP connectivty port for external and internal tableau apps"
}

variable "data_pipeline_RDP_TCP" {
  default     = false
  description = "RDP TCP connectivty port for data pipeline app"
}

variable "data_pipeline_custom_TCP" {
  default     = false
  description = "Custom TCP connectivty port for data pipeline app"
}

variable "data_ingest_RDP_TCP" {
  default     = false
  description = "RDP TCP connectivty port for data ingest app"
}

variable "data_ingest_custom_TCP" {
  default     = false
  description = "Custom TCP connectivty port for data ingest app"
}
