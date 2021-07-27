resource "aws_key_pair" "ssh" {
  key_name   = "${var.namespace}-ssh-keypair"
  public_key = var.ssh_pubkey

  tags = merge(
    { name = "${var.namespace}-ssh-keypair" },
    var.common_tags,
  )
}
