data "aws_route53_zone" "selected" {
  count = var.route53_zone == "" ? 0 : 1
  name  = var.route53_zone
}

resource "aws_route53_record" "cedge" {
  count   = var.route53_zone == "" ? 0 : 1
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = "${var.name}.${data.aws_route53_zone.selected[0].name}"
  type    = "A"
  ttl     = "300"
  records = [ "${aws_eip.cedge_eip.public_ip}" ]
}
