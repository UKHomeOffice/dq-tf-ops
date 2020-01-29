resource "aws_iam_role" "ops_win" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com",
        "Service": "s3.amazonaws.com",
        "Service": "ssm.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ops_win_athena" {
  name = "ops-win-athena-${local.naming_suffix}"
  role = "${aws_iam_role.ops_win.name}"

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
        "${join("\",\"", formatlist("arn:aws:s3:::%s-%s", var.dq_pipeline_ops_readwrite_bucket_list, var.namespace))}",
        "${join("\",\"", formatlist("arn:aws:s3:::%s-%s/*", var.dq_pipeline_ops_readwrite_bucket_list, var.namespace))}",
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
        "${join("\",\"", formatlist("arn:aws:s3:::%s-%s", var.dq_pipeline_ops_readonly_bucket_list, var.namespace))}",
        "${join("\",\"", formatlist("arn:aws:s3:::%s-%s/*", var.dq_pipeline_ops_readonly_bucket_list, var.namespace))}"
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
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ops_win" {
  role = "${aws_iam_role.ops_win.name}"
}
