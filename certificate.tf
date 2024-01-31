resource "aws_acm_certificate" "httpbin_cert" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# TODO: certificate validation could be used to assume certificate is created
#resource "aws_acm_certificate_validation" "certificate_validation" {
#}

data "aws_acm_certificate" "httpbin_cert" {
  domain      = aws_acm_certificate.httpbin_cert.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}
