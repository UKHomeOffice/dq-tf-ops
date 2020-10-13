resource "aws_instance" "mock-sftp-server-linux" {
  key_name                    = var.key_name
  ami                         = data.aws_ami.mock-sftp-server-linux.id
  instance_type               = "t2.medium"
  vpc_security_group_ids      = [aws_security_group.Bastions.id]
  subnet_id                   = aws_subnet.OPSSubnet.id
  private_ip                  = var.mock_sftp_server_linux_ip
  associate_public_ip_address = false
  monitoring                  = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "mock-sftp-server-linux-${local.naming_suffix}"
  }
}
