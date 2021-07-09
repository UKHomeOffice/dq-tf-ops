data "aws_ami" "analysis_ami" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-ops-httpd*",
    ]
  }

  owners = [
    "self",
  ]
}

resource "aws_instance" "analysis" {
  key_name                    = var.key_name
  ami                         = data.aws_ami.analysis_ami.id
  instance_type               = var.namespace == "prod" ? "m5.xlarge" : "m5a.xlarge"
  iam_instance_profile        = aws_iam_instance_profile.httpd_server_instance_profile.id
  vpc_security_group_ids      = [aws_security_group.analysis.id]
  associate_public_ip_address = true
  monitoring                  = true
  private_ip                  = var.analysis_instance_ip
  subnet_id                   = aws_subnet.ops_public_subnet.id

  user_data = <<EOF
#!/bin/bash

set -e

#log output from this user_data script
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

# start the cloud watch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -s -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

echo "
export s3_bucket_name=${var.s3_bucket_name}
export data_archive_bucket=${var.data_archive_bucket}-${var.namespace}
export AWS_ACCESS_KEY_ID=`aws --region eu-west-2 ssm get-parameter --name dq-tf-deploy-user-id-ops-${var.namespace}-dq --with-decryption --query 'Parameter.Value' --output text`
export AWS_SECRET_ACCESS_KEY=`aws --region eu-west-2 ssm get-parameter --name dq-tf-deploy-user-key-ops-${var.namespace}-dq --with-decryption --query 'Parameter.Value' --output text`
" > /root/.bashrc && source /root/.bashrc
export analysis_proxy_hostname=`aws --region eu-west-2 ssm get-parameter --name analysis_proxy_hostname --query 'Parameter.Value' --output text --with-decryption`

mkdir -p "/etc/letsencrypt/archive/""$analysis_proxy_hostname""-0001/"
mkdir -p "/etc/letsencrypt/live/""$analysis_proxy_hostname""-0001/"
mkdir -p "/etc/letsencrypt/live/""$analysis_proxy_hostname/"
aws s3 cp s3://$data_archive_bucket/analysis/letsencrypt/cert.pem "/etc/letsencrypt/archive/""$analysis_proxy_hostname""-0001/cert1.pem" --region eu-west-2
aws s3 cp s3://$data_archive_bucket/analysis/letsencrypt/privkey.pem "/etc/letsencrypt/archive/""$analysis_proxy_hostname""-0001/privkey1.pem" --region eu-west-2
aws s3 cp s3://$data_archive_bucket/analysis/letsencrypt/fullchain.pem "/etc/letsencrypt/archive/""$analysis_proxy_hostname""-0001/fullchain1.pem" --region eu-west-2
echo "#remove access to data_archive_bucket bucket from /root/.bashrc"
echo export s3_bucket_name=${var.s3_bucket_name} > /root/.bashrc && source /root/.bashrc
ln -s "/etc/letsencrypt/archive/""$analysis_proxy_hostname""-0001/cert1.pem" /etc/letsencrypt/live/""$analysis_proxy_hostname""-0001/cert.pem
ln -s "/etc/letsencrypt/archive/""$analysis_proxy_hostname""-0001/privkey1.pem" /etc/letsencrypt/live/""$analysis_proxy_hostname""-0001/privkey.pem
ln -s "/etc/letsencrypt/archive/""$analysis_proxy_hostname""-0001/fullchain1.pem" /etc/letsencrypt/live/""$analysis_proxy_hostname""-0001/fullchain.pem
ln -s "/etc/letsencrypt/archive/""$analysis_proxy_hostname""-0001/cert1.pem" /etc/letsencrypt/live/""$analysis_proxy_hostname/cert.pem
ln -s "/etc/letsencrypt/archive/""$analysis_proxy_hostname""-0001/privkey1.pem" /etc/letsencrypt/live/""$analysis_proxy_hostname/privkey.pem
ln -s "/etc/letsencrypt/archive/""$analysis_proxy_hostname""-0001/fullchain1.pem" /etc/letsencrypt/live/""$analysis_proxy_hostname/fullchain.pem
chmod 0644 "/etc/letsencrypt/archive/""$analysis_proxy_hostname""-0001/cert1.pem"
chmod 0644 "/etc/letsencrypt/archive/""$analysis_proxy_hostname""-0001/privkey1.pem"
chmod 0644 "/etc/letsencrypt/archive/""$analysis_proxy_hostname""-0001/fullchain1.pem"

echo "#Pull values from Parameter Store and save to profile"
touch /home/centos/ssl_expire_script/env_vars
echo "
export AWS_ACCESS_KEY_ID=`aws --region eu-west-2 ssm get-parameter --name dq-tf-deploy-user-id-ops-${var.namespace}-dq --with-decryption --query 'Parameter.Value' --output text`
export AWS_SECRET_ACCESS_KEY=`aws --region eu-west-2 ssm get-parameter --name dq-tf-deploy-user-key-ops-${var.namespace}-dq --with-decryption --query 'Parameter.Value' --output text`
export AWS_DEFAULT_REGION=eu-west-2
export GET_EXPIRY_COMMAND=`aws --region eu-west-2 ssm get-parameter --name analysis_proxy_certificate_get_expiry_command --with-decryption --query 'Parameter.Value' --output text`
export GET_REMOTE_EXPIRY_COMMAND=`aws --region eu-west-2 ssm get-parameter --name analysis_get_remote_expiry --with-decryption --query 'Parameter.Value' --output text`
export LIVE_CERTS=/etc/letsencrypt/live/`aws --region eu-west-2 ssm get-parameter --name analysis_proxy_hostname --with-decryption --query 'Parameter.Value' --output text`
export S3_FILE_LANDING=/home/centos/ssl_expire_script/remote_cert.pem
export BUCKET=${var.data_archive_bucket}-${var.namespace}
" > /home/centos/ssl_expire_script/env_vars

aws s3 cp s3://$s3_bucket_name/httpd.conf /etc/httpd/conf/httpd.conf --region eu-west-2
aws s3 cp s3://$s3_bucket_name/ssl.conf /etc/httpd/conf.d/ssl.conf --region eu-west-2

systemctl restart httpd


pip3 uninstall requests -y
pip3 uninstall six -y
pip3 uninstall urllib3 -y
yum install python-requests -y
yum install python-six -y
yum install python-urllib3 -y
python -m pip install --upgrade urllib3 --user
pip3 install pyOpenSSL==0.14 -U


systemctl restart httpd
EOF


  tags = {
    Name = "ec2-analysis-${local.naming_suffix}"
  }

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

resource "aws_security_group" "analysis" {
  vpc_id = aws_vpc.opsvpc.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = var.analysis_cidr_ingress
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      var.management_access,
    ]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "sg-analysis-${local.naming_suffix}"
  }
}

resource "aws_eip" "analysis_eip" {
  instance = aws_instance.analysis.id
  vpc      = true
}

resource "aws_route" "apps-tab" {
  route_table_id            = aws_route_table.ops_public_table.id
  destination_cidr_block    = var.route_table_cidr_blocks["apps_cidr"]
  vpc_peering_connection_id = var.vpc_peering_connection_ids["ops_and_apps"]
}

resource "aws_kms_key" "httpd_config_bucket_key" {
  description             = "This key is used to encrypt HTTPD config bucket objects"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_s3_bucket" "httpd_config_bucket" {
  bucket = var.s3_bucket_name
  acl    = var.s3_bucket_acl
  region = var.region

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.httpd_config_bucket_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = var.log_archive_s3_bucket
    target_prefix = "${var.service}-log/"
  }

  tags = {
    Name = "s3-${local.naming_suffix}"
  }
}

resource "aws_s3_bucket_metric" "httpd_config_bucket_logging" {
  bucket = var.s3_bucket_name
  name   = "httpd_config_bucket_metric"
}

resource "aws_s3_bucket_policy" "httpd_config_bucket" {
  bucket = var.s3_bucket_name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "HTTP",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": "arn:aws:s3:::${var.s3_bucket_name}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy" "httpd_linux_iam" {
  role = aws_iam_role.httpd_ec2_server_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": ["s3:ListBucket"],
          "Resource":
            "${aws_s3_bucket.httpd_config_bucket.arn}"
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:GetObject"
          ],
          "Resource":
            "${aws_s3_bucket.httpd_config_bucket.arn}/*"
        },
        {
          "Effect": "Allow",
          "Action": "kms:Decrypt",
          "Resource": "${aws_kms_key.httpd_config_bucket_key.arn}"
        },
        {
          "Effect": "Allow",
          "Action": [
              "ssm:GetParameter",
              "ssm:PutParameter"
          ],
          "Resource": [
            "arn:aws:ssm:eu-west-2:*:parameter/analysis_proxy_hostname",
            "arn:aws:ssm:eu-west-2:*:parameter/analysis_proxy_certificate",
            "arn:aws:ssm:eu-west-2:*:parameter/analysis_proxy_certificate_key",
            "arn:aws:ssm:eu-west-2:*:parameter/analysis_proxy_certificate_fullchain",
            "arn:aws:ssm:eu-west-2:*:parameter/dq-tf-deploy-user-id-ops-${var.namespace}-dq",
            "arn:aws:ssm:eu-west-2:*:parameter/dq-tf-deploy-user-key-ops-${var.namespace}-dq",
            "arn:aws:ssm:eu-west-2:*:parameter/analysis_proxy_certificate_get_expiry_command",
            "arn:aws:ssm:eu-west-2:*:parameter/analysis_get_remote_expiry"
          ]
        }
    ]
}
EOF

}

resource "aws_iam_role" "httpd_ec2_server_role" {
  name = "httpd_ec2_server_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [ "ec2.amazonaws.com",
                     "s3.amazonaws.com" ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "httpd_ec2_server_CWagent" {
  role       = aws_iam_role.httpd_ec2_server_role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "httpd_server_instance_profile" {
  name = "httpd_server_instance_profile"
  role = aws_iam_role.httpd_ec2_server_role.name
}

variable "s3_bucket_acl" {
  default = "private"
}

variable "region" {
  default = "eu-west-2"
}

variable "service" {
  default     = "dq-httpd-ops"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.5 document"
}

variable "analysis_instance_ip" {
}

variable "analysis_cidr_ingress" {
  type = list(string)

  default = [
    "62.25.109.196/32",
    "80.169.158.34/32",
    "80.193.85.91/32",
    "86.188.197.170/32",
    "86.188.197.168/32",
    "86.188.197.169/32",
    "86.188.197.171/32",
    "86.188.197.172/32",
    "86.188.197.173/32",
    "86.188.197.174/32",
    "86.188.197.175/32",
    "52.48.127.150/32",
    "52.48.127.151/32",
    "52.48.127.152/32",
    "52.48.127.153/32",
    "52.209.62.128/25",
    "52.56.62.128/25",
    "35.177.179.157/32",
    "31.221.110.80/29",
    "195.95.131.0/24",
    "5.148.69.20/32",
    "5.148.32.192/26",
    "193.164.115.0/24",
    "203.63.205.64/28",
    "5.148.32.229/32",
    "119.73.144.40/32",
    "85.211.101.55/32",
  ]
}

variable "management_access" {
}

variable "s3_bucket_name" {
}

output "analysis_eip" {
  value = aws_eip.analysis_eip.public_ip
}

module "ec2_alarms" {
  source = "github.com/UKHomeOffice/dq-tf-cloudwatch-ec2"

  naming_suffix   = local.naming_suffix
  environment     = var.naming_suffix
  pipeline_name   = "analysis-ec2"
  ec2_instance_id = aws_instance.analysis.id
}
