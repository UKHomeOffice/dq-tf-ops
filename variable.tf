variable "account_id" {
  type = map(string)
  default = {
    "notprod" = "483846886818"
    "prod"    = "337779336338"
  }
}

variable "cidr_block" {
}

variable "vpc_subnet_cidr_block" {
}

variable "public_subnet_cidr_block" {
}

variable "ad_subnet_cidr_block" {
}

variable "az" {
}

variable "naming_suffix" {
}

variable "ad_aws_ssm_document_name" {
}

variable "ad_writer_instance_profile_name" {
}

variable "log_archive_s3_bucket" {
}

variable "namespace" {
}

variable "ops_config_bucket" {
}

variable "athena_maintenance_bucket" {
}

variable "vpc_peering_connection_ids" {
  description = "Map of VPC peering IDs for the Ops route table."
  type        = map(string)
}

variable "route_table_cidr_blocks" {
  description = "Map of CIDR blocks for the OPs private route table."
  type        = map(string)
}

variable "bastion_linux_ip" {
  description = "Mock EC2 instance IP"
}

variable "bastions_windows_ip" {
  description = "All Win bastion IP addresses"
}

variable "test_bastions_windows_ip" {
  description = "Test Win bastion IP addresses"
}

variable "ad_sg_cidr_ingress" {
  description = "List of CIDR block ingress to AD machines SG"
  type        = list(string)
}

variable "key_name" {
  description = "Default SSH key name for EC2 instances"
  default     = "test_instance"
}

variable "athena_log_bucket" {
  description = "Athena log bucket ARN"
}

variable "aws_bucket_key" {
  description = "S3 bucket KMS key"
}

variable "tableau_deployment_ip" {
  description = "Tableau Deployment IP address"
  default     = "10.0.0.1"
}


variable "tableau_subnet_cidr_block" {
  description = "Tableau Dev CIDR block"
}

variable "dq_pipeline_ops_readwrite_database_name_list" {
  description = "RW Database list from dq-tf-apps"
  type        = list(string)
}

variable "dq_pipeline_ops_readonly_database_name_list" {
  description = "RO Database list from dq-tf-apps"
  type        = list(string)
}

variable "dq_pipeline_ops_readwrite_bucket_list" {
  description = "RW Bucket list from dq-tf-apps"
  type        = list(string)
}

variable "dq_pipeline_ops_readonly_bucket_list" {
  description = "RO Bucket list from dq-tf-apps"
  type        = list(string)
}

variable "apps_aws_bucket_key" {
  description = "Apps KMS key"
}

variable "ops_config_acl" {
  default = "private"
}

variable "athena_maintenance_acl" {
  default = "private"
}

variable "data_archive_bucket_name" {
  default = "s3-dq-data-archive-bucket"
}

variable "httpd_config_bucket_name" {
  default = "s3-dq-httpd-config-bucket"
}



variable "management_access" {
}
