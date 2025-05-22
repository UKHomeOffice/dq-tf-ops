# Linux Bastion log groups
resource "aws_cloudwatch_log_group" "bastion_linux" {

  name = "Linux_Bastion/messages"

  tags = {
    Name = "Linux_Bastion/messages"
  }
}

resource "aws_cloudwatch_log_group" "bastion_linux_secure" {

  name = "Linux_Bastion/secure"

  tags = {
    Name = "Linux_Bastion/secure"
  }
}