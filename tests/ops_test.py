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
              vpc_peering_to_peering_id = "1234"
              peering_to_acpvpn_id      = "1234"
              route_table_cidr_blocks   = {
                  name = "1234"
                  name2 = "1234"
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

    def test_name_rti(self):
        self.assertEqual(self.result['ops']["aws_internet_gateway.OpsRouteToInternet"]["tags.Name"], "dq-ops-igw")

    def test_name_bastions_sg(self):
        self.assertEqual(self.result['ops']["aws_security_group.Bastions"]["tags.Name"], "dq-ops-sg")

    def test_name_prefix_opsvpc(self):
        self.assertEqual(self.result['ops']["aws_vpc.opsvpc"]["tags.Name"], "dq-ops-vpc")

if __name__ == '__main__':
    unittest.main()
