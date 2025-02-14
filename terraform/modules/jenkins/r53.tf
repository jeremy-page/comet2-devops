

# Hosted Zone
resource "aws_route53_zone" "comet_zone" {
  name = var.zone_name #"black.icf-comet-cc.com"  
}

#  ACM Certificate for the domain & wildcard subdomain
resource "aws_acm_certificate" "comet_cert" {
  domain_name               = var.acm_cert_domain #"black.icf-comet-cc.com" 
  subject_alternative_names = var.acm_cert_alt_domain #["*.black.icf-comet-cc.com"] 
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#  Route 53 DNS Records for ACM Validation
resource "aws_route53_record" "comet_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.comet_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.comet_zone.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 300
}

# Validate the ACM Certificate
# resource "aws_acm_certificate_validation" "comet_cert_validation" {
#   certificate_arn         = aws_acm_certificate.comet_cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.comet_cert_validation : record.fqdn]
# }
