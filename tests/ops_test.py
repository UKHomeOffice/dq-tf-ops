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
                aws = "aws"
              }

              cidr_block                = "10.2.0.0/16"
              vpc_subnet_cidr_block     = "10.2.1.0/24"
              public_subnet_cidr_block  = "1.1.1.0/24"
              ad_subnet_cidr_block      = "1.1.1.0/24"
              az                        = "eu-west-2a"
              naming_suffix             = "preprod-dq"
              bastion_linux_ip          = "1.2.3.4"
              bastion_windows_ip        = "1.2.3.4"
              bastion2_windows_ip       = "1.2.3.4"
              ad_aws_ssm_document_name  = "1234"
              ad_writer_instance_profile_name = "1234"
              adminpassword             = "1234"
              log_archive_s3_bucket     = "abcd"
              s3_bucket_name            = "dq-test"
              management_access         = "10.1.1.1/32"
              analysis_instance_ip      = "10.1.1.1/32"

              route_table_cidr_blocks   = {
                peering_cidr = "1234"
                apps_cidr = "1234"
                acp_vpn = "1234"
                acp_prod = "1234"
                acp_ops = "1234"
                acp_cicd = "1234"
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
        self.result = Runner(self.snippet).result

    def test_root_destroy(self):
        self.assertEqual(self.result["destroy"], False)

    def test_vpc_cidr_block(self):
        self.assertEqual(self.result['ops']["aws_vpc.opsvpc"]["cidr_block"], "10.2.0.0/16")

    def test_subnet_cidr_block(self):
        self.assertEqual(self.result['ops']["aws_subnet.OPSSubnet"]["cidr_block"], "10.2.1.0/24")

    def test_az(self):
        self.assertEqual(self.result['ops']["aws_subnet.OPSSubnet"]["availability_zone"], "eu-west-2a")

    def test_name_bastions_sg(self):
        self.assertEqual(self.result['ops']["aws_security_group.Bastions"]["tags.Name"], "sg-bastions-ops-preprod-dq")

    def test_name_suffix_opsvpc(self):
        self.assertEqual(self.result['ops']["aws_vpc.opsvpc"]["tags.Name"], "vpc-ops-preprod-dq")

    def test_name_suffix_ad_subnet(self):
        self.assertEqual(self.result['ops']["aws_subnet.ad_subnet"]["tags.Name"], "ad-subnet-ops-preprod-dq")

    def test_name_bastion2(self):
        self.assertEqual(self.result['ops']["aws_instance.bastion_win2"]["tags.Name"], "bastion2-win-ops-preprod-dq")


if __name__ == '__main__':
    unittest.main()
