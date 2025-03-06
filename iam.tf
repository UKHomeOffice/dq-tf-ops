resource "aws_iam_role" "ops_win" {
  name               = "ops-win"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
                   "ec2.amazonaws.com",
                   "s3.amazonaws.com",
                   "ssm.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "ops_win_athena" {
  name = "ops-win-athena-${local.naming_suffix}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:ListMultipartUploadParts",
                "s3:AbortMultipartUpload",
                "s3:PutObject",
                "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${join(
  "\",\"",
  formatlist(
    "arn:aws:s3:::%s-%s",
    var.dq_pipeline_ops_readwrite_bucket_list,
    var.namespace,
  ),
  )}",
        "${join(
  "\",\"",
  formatlist(
    "arn:aws:s3:::%s-%s/*",
    var.dq_pipeline_ops_readwrite_bucket_list,
    var.namespace,
  ),
  )}",
        "arn:aws:s3:::${var.ops_config_bucket}",
        "arn:aws:s3:::${var.ops_config_bucket}/*"
      ]
    },
    {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": [
                "*"
            ]

    },
    {
      "Action": [
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${join(
  "\",\"",
  formatlist(
    "arn:aws:s3:::%s-%s",
    var.dq_pipeline_ops_readonly_bucket_list,
    var.namespace,
  ),
  )}",
        "${join(
  "\",\"",
  formatlist(
    "arn:aws:s3:::%s-%s/*",
    var.dq_pipeline_ops_readonly_bucket_list,
    var.namespace,
  ),
)}"
      ]
    },
    {
      "Action": [
        "athena:StartQueryExecution",
        "athena:GetQueryExecution",
        "athena:GetQueryResults",
        "athena:GetQueryResultsStream",
        "athena:UpdateWorkGroup",
        "athena:GetWorkGroup"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "glue:GetDatabase",
        "glue:GetDatabases",
        "glue:CreateTable",
        "glue:DeleteTable",
        "glue:GetTable",
        "glue:GetTables",
        "glue:GetPartition",
        "glue:GetPartitions",
        "glue:BatchCreatePartition",
        "glue:BatchDeletePartition"
      ],
      "Effect": "Allow",
      "Resource": [
          "*"
      ]
    },
    {
      "Action": [
        "ssm:GetParameter"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:ssm:eu-west-2:*:parameter/AD_Domain_Joiner_Username",
          "arn:aws:ssm:eu-west-2:*:parameter/AD_Domain_Joiner_Password"
      ]
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": "${var.apps_aws_bucket_key}"
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": "${data.aws_kms_key.glue.arn}"
    },
    {
      "Action": [
        "states:List*",
        "states:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
         "ec2:ModifyInstanceMetadataOptions"
      ],
      "Resource": "arn:aws:ec2:*:*:instance/*"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "dq_tf_infra_write_to_cw_ops" {
  role       = aws_iam_role.ops_win.id
  policy_arn = "arn:aws:iam::${var.account_id[var.namespace]}:policy/dq-tf-infra-write-to-cw"
}

resource "aws_iam_role_policy_attachment" "ops_win_athena" {
  role       = aws_iam_role.ops_win.name
  policy_arn = aws_iam_policy.ops_win_athena.arn
}

resource "aws_iam_instance_profile" "ops_win" {
  role = aws_iam_role.ops_win.name
}

# add dq-tf-deploy user to be used by drone pipleines

resource "aws_iam_user" "deploy_user" {
  name   = "dq-tf-deploy-${local.naming_suffix}"
}

resource "aws_iam_access_key" "deploy_user" {
  user   = aws_iam_user.deploy_user.name
  status = "Inactive"
}

resource "aws_ssm_parameter" "deploy_user_id" {
  name  = "dq-tf-deploy-user-id-${local.naming_suffix}"
  type  = "SecureString"
  value = aws_iam_access_key.deploy_user.id
}

resource "aws_ssm_parameter" "deploy_user_key" {
  name  = "dq-tf-deploy-user-key-${local.naming_suffix}"
  type  = "SecureString"
  value = aws_iam_access_key.deploy_user.secret
}

resource "aws_iam_user_group_membership" "deploy_user_group" {
  user = aws_iam_user.deploy_user.name

  groups = [
    "dq-tf-infra",
    "kms-fullaccess"
  ]
}

resource "aws_iam_role" "ops_linux" {
  name               = "ops-linux"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
                   "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "ops_linux" {

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [   
    {
      "Effect": "Allow",
      "Action": [
         "ec2:ModifyInstanceMetadataOptions"
      ],
      "Resource": "arn:aws:ec2:*:*:instance/*"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "ops_linux_policy_attach" {
  role       = aws_iam_role.ops_linux.id
  policy_arn = aws_iam_policy.ops_linux.arn
}

resource "aws_iam_instance_profile" "ops_linux" {
  role = aws_iam_role.ops_linux.name
}

// # add dq-tf-compliance user to be used by drone pipleines for compliance jobs

// resource "aws_iam_user" "compliance_user" {
//   name = "dq-tf-compliance-${local.naming_suffix}"
// }

// resource "aws_iam_access_key" "compliance_user" {
//   user = aws_iam_user.compliance_user.name
// }

// resource "aws_ssm_parameter" "compliance_user_id" {
//   name  = "dq-tf-compliance-user-id-${local.naming_suffix}"
//   type  = "SecureString"
//   value = aws_iam_access_key.compliance_user.id
// }

// resource "aws_ssm_parameter" "compliance_user_key" {
//   name  = "dq-tf-compliance-user-key-${local.naming_suffix}"
//   type  = "SecureString"
//   value = aws_iam_access_key.compliance_user.secret
// }

// resource "aws_iam_user_group_membership" "compliance_user_group" {
//   user = aws_iam_user.compliance_user.name

//   groups = [
//     "dq-compliance"
//   ]
// }
