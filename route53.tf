resource "aws_route53_zone" "this" {
  name    = "httpbin-ft.etvnet.com"
  comment = "Zone for Freelancer's test"
  lifecycle { prevent_destroy = true }
}

# TODO: solution could be nicer
locals {
  site_fqdn = flatten(["www.${var.domain_name}", "${var.domain_name}"])
}

resource "aws_route53_record" "dns_records" {
  for_each = toset(local.site_fqdn)
  zone_id  = aws_route53_zone.this.zone_id
  name     = each.value
  type     = "A"

  alias {
    name                   = one(aws_lb.lb_httpbin.*.dns_name)
    zone_id                = one(aws_lb.lb_httpbin.*.zone_id)
    evaluate_target_health = true
  }
}
