provider "aws" {
  region = "${var.region}"
  # si usan profile descomentar la siguiente linea
   profile = "${var.profile}"
}

data "aws_route53_zone" "zone" {
  name         = "${var.zone_name}"
}

data "aws_lb" "loadbalancer" {
  name = "${var.lb_name}"
}

data "aws_instance" "instance" {
  filter {
    name   = "tag:Name"
    values = ["${var.inst_name}"]
  }
}

resource "aws_route53_record" "site" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${var.site_name}"
  type    = "A"
  alias {
    name                   = "${data.aws_lb.loadbalancer.dns_name}"
    zone_id                = "${data.aws_lb.loadbalancer.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_lb_target_group" "tg_resource" {
  name     = "${var.tg_name}"
    port     = "${var.port}"
    protocol = "HTTP"
    target_type = "instance"
    vpc_id = "${var.vpc_id}"

  health_check {
    interval            = 30
    path                = "/index.html"
    port                = "${var.port}"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,202,303"
  }
}

resource "aws_lb_target_group_attachment" "tg_attach" {
  target_group_arn = "${aws_lb_target_group.tg_resource.arn}"
  target_id        = "${data.aws_instance.instance.id}"
  port             = "${var.port}"
}

