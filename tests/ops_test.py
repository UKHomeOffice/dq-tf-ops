# pylint: disable=missing-docstring, line-too-long, protected-access, E1101, C0202, E0602, W0109
import unittest
from runner import Runner


class TestE2E(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.snippet = """

            provider "aws" {
              region = "eu-west-2"
              skip_credentials_validation = true
              skip_get_ec2_platforms = true
            }

            module "ops" {
              source = "./mymodule"

              providers = {
                aws = aws
              }

              cidr_block                      = "10.2.0.0/16"
              vpc_subnet_cidr_block           = "10.2.1.0/24"
              public_subnet_cidr_block        = "1.1.1.0/24"
              ad_subnet_cidr_block            = "1.1.1.0/24"
              az                              = "eu-west-2a"
              naming_suffix                   = "preprod-dq"
              namespace                       = "notprod"
              domain_joiner_pwd               = "pwd"
              bastion_linux_ip                = "10.8.0.11"
              bastions_windows_ip             = ["10.8.0.12", "10.8.0.13", "10.8.0.14", "10.8.0.15"]
              test_bastions_windows_ip        = ["10.8.0.16", "10.8.0.17"]
              ad_aws_ssm_document_name        = "1234"
              ad_writer_instance_profile_name = "1234"
              adminpassword                   = "1234"
              log_archive_s3_bucket           = "abcd"
              httpd_config_bucket_name        = "dq-test"
              data_archive_bucket_name        = "dq-test"
              ops_config_bucket               = "s3-dq-ops-config"
              athena_maintenance_bucket       = "ops_athena_maintenance_bucket"
              management_access               = "10.1.1.1/32"
              analysis_instance_ip            = "10.1.1.1"
              athena_log_bucket               = "athena_log_bucket"
              aws_bucket_key                  = "111122223333"
              tableau_deployment_ip           = ["1.2.3.5"]
              tableau_subnet_cidr_block       = "10.1.1.1/32"
              apps_aws_bucket_key             = "arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
              dq_pipeline_ops_readwrite_database_name_list       = ["api_input"]
              dq_pipeline_ops_readonly_database_name_list        = ["api_input"]
              dq_pipeline_ops_readwrite_bucket_list              = ["s3-bucket-name"]
              dq_pipeline_ops_readonly_bucket_list               = ["s3-bucket-name"]

              route_table_cidr_blocks   = {
                peering_cidr = "10.2.0.0/16"
                apps_cidr = "10.3.0.0/16"
                acp_vpn = "10.4.0.0/16"
              }
              vpc_peering_connection_ids = {
                ops_and_apps = "1234"
                ops_and_peering = "1234"
                ops_and_acpvpn = "1234"
              }
              ad_sg_cidr_ingress = [
                "1.2.0.0/16",
                "1.2.0.0/16",
                "1.2.0.0/16"
              ]
            }
        """
        self.runner = Runner(self.snippet)
        self.result = self.runner.result

    def test_vpc_cidr_block(self):
        self.assertEqual(self.runner.get_value("module.ops.aws_vpc.opsvpc", "cidr_block"), "10.2.0.0/16")

    def test_subnet_cidr_block(self):
        self.assertEqual(self.runner.get_value("module.ops.aws_subnet.OPSSubnet", "cidr_block"), "10.2.1.0/24")

    def test_az(self):
        self.assertEqual(self.runner.get_value("module.ops.aws_subnet.OPSSubnet", "availability_zone"), "eu-west-2a")

    def test_name_bastions_sg(self):
        self.assertEqual(self.runner.get_value("module.ops.aws_security_group.Bastions", "tags"), {"Name": "sg-bastions-ops-preprod-dq"})

    def test_name_suffix_opsvpc(self):
        self.assertEqual(self.runner.get_value("module.ops.aws_vpc.opsvpc", "tags"), {"Name": "vpc-ops-preprod-dq"})

    def test_name_suffix_ad_subnet(self):
        self.assertEqual(self.runner.get_value("module.ops.aws_subnet.ad_subnet", "tags"), {"Name": "ad-subnet-ops-preprod-dq"})

    def test_name_bastion(self):
        self.assertEqual(self.runner.get_value("module.ops.aws_instance.win_bastions[0]", "tags"), {"Name": "win-bastion-1-ops-preprod-dq"})
        
if __name__ == '__main__':
    unittest.main()
