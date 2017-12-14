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
              az                        = "eu-west-2a"
              name_prefix               = "dq-"
              bastion_linux_ip          = "1.2.3.4"
              bastion_windows_ip        = "1.2.3.4"
              BDM_HTTPS_TCP             = 443
              BDM_SSH_TCP               = 22
              BDM_CUSTOM_TCP            = 5432
              INT_EXT_TABLEAU_RDP_TCP   = 3389
              INT_EXT_TABLEAU_HTTPS_TCP = 443
              data_pipeline_RDP_TCP     = 3389
              data_pipeline_custom_TCP  = 1433
              data_ingest_RDP_TCP       = 3389
              data_ingest_custom_TCP    = 5432
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
        self.assertEqual(self.result['ops']["aws_security_group.Bastions"]["tags.Name"], "dq-ops-sg")

    def test_name_prefix_opsvpc(self):
        self.assertEqual(self.result['ops']["aws_vpc.opsvpc"]["tags.Name"], "dq-ops-vpc")

if __name__ == '__main__':
    unittest.main()
