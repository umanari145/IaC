#----------------------------------------
# ALBの作成
#----------------------------------------
resource "aws_lb" "sample-alb" {
  name               = "sample-alb"
  security_groups = [
    aws_security_group.elb-sg.id
  ]
  subnets = [for subnet in aws_subnet.webap_subnet : subnet.id]
}
#----------------------------------------
# ターゲットグループの作成
#----------------------------------------
resource "aws_lb_target_group" "tg-elb" {
  name     = "tg-elb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path = "/"
  }
}
#----------------------------------------
# インスタンスにTGを設定
#----------------------------------------
resource "aws_lb_target_group_attachment" "ec2-ap" {
  count    = 2
  target_group_arn = aws_lb_target_group.tg-elb.arn
  target_id  = "${element(aws_instance.sample-instance.*.id, count.index)}"
  port             = 80
}

#----------------------------------------
# ALBリスナーの作成
#----------------------------------------
resource "aws_lb_listener" "elb-alb" {
  load_balancer_arn = aws_lb.sample-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-elb.arn
  }
}
#----------------------------------------
#リスナールールの作成
#----------------------------------------
resource "aws_lb_listener_rule" "forward" {
  listener_arn = aws_lb_listener.elb-alb.arn
  priority     = 99
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-elb.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
