variable "cidr_block" {}
variable "vpc_subnet_cidr_block" {}
variable "public_subnet_cidr_block" {}
variable "ad_subnet_cidr_block" {}
variable "az" {}
variable "naming_suffix" {}
variable "ad_aws_ssm_document_name" {}
variable "ad_writer_instance_profile_name" {}
variable "adminpassword" {}
variable "log_archive_s3_bucket" {}

variable "vpc_peering_connection_ids" {
  description = "Map of VPC peering IDs for the Ops route table."
  type        = "map"
}

variable "route_table_cidr_blocks" {
  description = "Map of CIDR blocks for the OPs private route table."
  type        = "map"
}

variable "bastion_win_id" {
  default     = "01-"
  description = "Identification number for Bastion Host Windows Instance"
}

variable "bastion_linux_id" {
  default     = "01-"
  description = "Identification number for Bastion Host Linux Instance"
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

variable "bastion2_windows_ip" {
  description = "2nd Win bastion IP address"
}

variable "ad_sg_cidr_ingress" {
  description = "List of CIDR block ingress to AD machines SG"
  type        = "list"
}

variable "key_name" {
  description = "Default SSH key name for EC2 instances"
  default     = "test_instance"
}
