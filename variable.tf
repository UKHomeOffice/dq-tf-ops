variable "cidr_block" {}
variable "vpc_subnet_cidr_block" {}
variable "public_subnet_cidr_block" {}
variable "ad_subnet_cidr_block" {}
variable "az" {}
variable "name_prefix" {}
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

variable "service" {
  default     = "dq-bastion-host-"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.5 document"
}

variable "environment" {
  default     = "preprod-"
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

variable "BDM_instance_ip" {
  default     = "10.1.10.11"
  description = "Mock IP address of EC2 instance for BDM app"
}

variable "BDM_RDS_db_instance_ip" {
  default     = false
  description = "IP address of EC2 db instance for BDM app"
}

variable "INT_EXT_TABLEAU_RDP_TCP" {
  default     = false
  description = "RDP TCP connectivty port for external and internal tableau apps"
}

variable "internal_dashboard_instance_ip" {
  default     = "10.1.12.11"
  description = "Mock IP address of EC2 instance for internal tableau apps"
}

variable "external_dashboard_instance_ip" {
  default     = "10.1.14.11"
  description = "Mock IP address of EC2 instance for external tableau apps"
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

variable "dp_postgres_ip" {
  default     = "10.1.8.11"
  description = "Mock EC2 database instance for data pipeline app"
}

variable "dp_web_ip" {
  default     = "10.1.8.21"
  description = "Mock EC2 web instance for data pipeline app"
}

variable "data_ingest_RDP_TCP" {
  default     = false
  description = "RDP TCP connectivty port for data ingest app"
}

variable "data_ingest_custom_TCP" {
  default     = false
  description = "Custom TCP connectivty port for data ingest app"
}

variable "data_ingest_web_ip" {
  default     = "10.1.6.21"
  description = "Mock EC2 web instance for data ingest app"
}

variable "data_ingest_db_ip" {
  default     = "10.1.6.11"
  description = "Mock EC2 database instance for data ingest app"
}

variable "external_feed_RDP_TCP" {
  default     = false
  description = "RDP TCP connectivty port for external feed app"
}

variable "external_feed_custom_TCP" {
  default     = false
  description = "Custom TCP connectivty port for external feed app"
}

variable "df_postgres_ip" {
  default     = "10.1.4.11"
  description = "Mock IP address of database EC2 instance for external data feeds app"
}

variable "df_web_ip" {
  default     = "10.1.4.21"
  description = "Mock IP address of web EC2 instance for external data feeds app"
}

variable "gp_SSH_TCP" {
  default     = 22
  description = "SSH TCP connectivty port for greenplum database"
}

variable "ACP_VPN_IP" {
  default     = "10.4.1.10"
  description = "IP address for the ACP VPN"
}

variable "ACP_port" {
  default     = 80
  description = "Connectivity port for ACP traffic"
}
