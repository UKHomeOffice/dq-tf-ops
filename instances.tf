resource "aws_instance" "bastion_linux" {
  key_name                    = var.key_name
  ami                         = data.aws_ami.bastion_linux.id
  instance_type               = "t3a.medium"
  vpc_security_group_ids      = [aws_security_group.Bastions.id]
  subnet_id                   = aws_subnet.OPSSubnet.id
  private_ip                  = var.bastion_linux_ip
  associate_public_ip_address = false
  monitoring                  = true

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      user_data,
      ami,
      instance_type,
    ]
  }

  tags = {
    Name = "bastion-linux-${local.naming_suffix}"
  }
}

resource "aws_instance" "win_bastions" {
  count                       = var.namespace == "prod" ? "2" : "2" # normally 2 - for Win Bastion 1 & Win Bastion 2
  key_name                    = var.key_name
  ami                         = data.aws_ami.win.id
  instance_type               = "t3a.xlarge"
  vpc_security_group_ids      = [aws_security_group.Bastions.id]
  iam_instance_profile        = aws_iam_instance_profile.ops_win.id
  subnet_id                   = aws_subnet.OPSSubnet.id
  private_ip                  = element(var.bastions_windows_ip, count.index)
  associate_public_ip_address = false
  monitoring                  = true

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      user_data,
      ami,
      instance_type
    ]
  }

  tags = {
    Name = "win-bastion-${count.index + 1}-${local.naming_suffix}"
  }
}

# The preferred format (Target: Key, Values) does not work
# - maybe I've got the format/syntax wrong but I've tried many variations
#resource "aws_ssm_association" "win_bastions" {
#  name        = var.ad_aws_ssm_document_name
#  targets {
#    key    = "InstanceIds"
#    values = [aws_instance.win_bastions[0].id, aws_instance.win_bastions[1].id] # "${element(aws_instance.win_bastions.id, count.index)}"
#  }
#}

# Although `instance_id` is deprecated, it does still work
resource "aws_ssm_association" "win_bastion1" {
  name        = var.ad_aws_ssm_document_name
  instance_id = aws_instance.win_bastions[0].id
}

resource "aws_ssm_association" "win_bastion2" {
  name        = var.ad_aws_ssm_document_name
  instance_id = aws_instance.win_bastions[1].id
}


resource "aws_security_group" "Bastions" {
  vpc_id = aws_vpc.opsvpc.id

  tags = {
    Name = "sg-bastions-${local.naming_suffix}"
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    cidr_blocks = ["${var.namespace == "prod" ? "10.2" : "10.8"}.0.0/24"]
  }

  ingress {
    from_port   = 111
    to_port     = 111
    protocol    = "udp"
    cidr_blocks = ["${var.namespace == "prod" ? "10.2" : "10.8"}.0.0/24"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["${var.namespace == "prod" ? "10.2" : "10.8"}.0.0/24"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "udp"
    cidr_blocks = ["${var.namespace == "prod" ? "10.2" : "10.8"}.0.0/24"]
  }

  ingress {
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["${var.namespace == "prod" ? "10.2" : "10.8"}.0.0/24"]
  }

  ingress {
    from_port   = 445
    to_port     = 445
    protocol    = "udp"
    cidr_blocks = ["${var.namespace == "prod" ? "10.2" : "10.8"}.0.0/24"]
  }

  ingress {
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    cidr_blocks = ["${var.namespace == "prod" ? "10.2" : "10.8"}.0.0/24"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.namespace == "prod" ? "10.44.168" : "10.44.152"}.0/21"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.namespace == "prod" ? "10.44.168" : "10.44.152"}.0/21"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ops_tableau" {
  source = "github.com/UKHomeOffice/dq-tf-ops-tableau"

  key_name                                     = var.key_name
  tableau_deployment_ip                        = var.tableau_deployment_ip
  opsvpc_id                                    = aws_vpc.opsvpc.id
  tableau_subnet_cidr_block                    = var.tableau_subnet_cidr_block
  vpc_subnet_cidr_block                        = var.vpc_subnet_cidr_block
  naming_suffix                                = local.naming_suffix
  az                                           = var.az
  route_table_id                               = aws_route_table.ops_route_table.id
  ops_config_bucket                            = var.ops_config_bucket
  apps_aws_bucket_key                          = var.apps_aws_bucket_key
  namespace                                    = var.namespace
  dq_pipeline_ops_readwrite_bucket_list        = var.dq_pipeline_ops_readwrite_bucket_list
  dq_pipeline_ops_readonly_bucket_list         = var.dq_pipeline_ops_readonly_bucket_list
  dq_pipeline_ops_readwrite_database_name_list = var.dq_pipeline_ops_readwrite_database_name_list
  dq_pipeline_ops_readonly_database_name_list  = var.dq_pipeline_ops_readonly_database_name_list
}
