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
  name   = "ops-win-athena-${local.naming_suffix}"
  role   = "${aws_iam_role.ops_win.name}"
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
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [
              "arn:aws:s3:::${var.athena_log_bucket}",
              "arn:aws:s3:::${var.athena_log_bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "${var.aws_bucket_key}"
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
            "glue:GetTable",
            "glue:GetTables",
            "glue:GetPartition",
            "glue:GetPartitions"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:glue:eu-west-2:${data.aws_caller_identity.current.account_id}:database/default",
            "${join("\",\"",formatlist("arn:aws:glue:eu-west-2:${data.aws_caller_identity.current.account_id}:database/%s_%s", var.dq_pipeline_ops_readonly_database_name_list, var.naming_suffix))}",
            "${join("\",\"",formatlist("arn:aws:glue:eu-west-2:${data.aws_caller_identity.current.account_id}:table/%s_%s/*", var.dq_pipeline_ops_readonly_database_name_list, var.naming_suffix))}"
          ]
        },
    ]
}
EOF
}

resource "aws_iam_instance_profile" "ops_win" {
  role = "${aws_iam_role.ops_win.name}"
}
