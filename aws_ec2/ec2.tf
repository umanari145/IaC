#変数を動的に取得したい時
data aws_ssm_parameter amzn2_ami {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "sample-instance" {
    count = 2
    ami = data.aws_ssm_parameter.amzn2_ami.value
    instance_type = "t2.micro"
    subnet_id = "${element(aws_subnet.webap_subnet.*.id, count.index)}"
    key_name = aws_key_pair.key_pair.id
    vpc_security_group_ids = [aws_security_group.web_server_sg.id]
    #↓これを入れないとそもそもパブリックIPが付与されないので注意
    associate_public_ip_address = true
    tags = {
      Name = "${format("webAP-%02d", count.index + 1)}"
    }

  user_data = <<EOF
#! /bin/bash
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
EOF

}