variable public_key_file {}
variable private_key_file {}
variable key_pair_name {}
variable owner_user{}

#秘密鍵のロジック
resource "tls_private_key" "keygen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ローカルにファイルを作成するコマンド(秘密鍵)
resource "local_file" "generate_private_key_pem" {
  filename = "${var.private_key_file}"
  # ファイルの内容
  content  = "${tls_private_key.keygen.private_key_pem}"

  provisioner "local-exec" {
    command = "chmod 600 ${var.private_key_file} && chown ${var.owner_user} ${var.public_key_file}"
  }
}

# ローカルにファイルを作成するコマンド(公開鍵)
resource "local_file" "generate_public_key_openssh" {
  filename = "${var.public_key_file}"
  content  = "${tls_private_key.keygen.public_key_openssh}"

  # local_fileでファイルを作ると実行権限が付与されてしまうので、local-execでchmodしておく。
  provisioner "local-exec" {
    command = "chmod 600 ${var.public_key_file} && chown ${var.owner_user} ${var.public_key_file}"
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.key_pair_name}"
  public_key = "${tls_private_key.keygen.public_key_openssh}"
}

