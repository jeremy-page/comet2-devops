

# Hosted Zone - Create this manually due to the dependency on the Navy account
# resource "aws_route53_zone" "comet_zone" {
#   name = var.zone_name #"black.icf-comet-cc.com"  
# }

#  ACM Certificate for the domain & wildcard subdomain
resource "aws_acm_certificate" "comet_cert" {
  domain_name               = var.acm_cert_domain     #"black.icf-comet-cc.com" 
  subject_alternative_names = var.acm_cert_alt_domain #["*.black.icf-comet-cc.com"] 
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_route53_record" "comet_cert_validation" {
  depends_on = [aws_acm_certificate.comet_cert]

  zone_id = data.aws_route53_zone.comet_zone.zone_id

  # Lookup ACM validation records only for the main domain
  name    = lookup({ for dvo in aws_acm_certificate.comet_cert.domain_validation_options : dvo.domain_name => dvo.resource_record_name }, var.acm_cert_domain, null)
  type    = lookup({ for dvo in aws_acm_certificate.comet_cert.domain_validation_options : dvo.domain_name => dvo.resource_record_type }, var.acm_cert_domain, null)
  records = [lookup({ for dvo in aws_acm_certificate.comet_cert.domain_validation_options : dvo.domain_name => dvo.resource_record_value }, var.acm_cert_domain, null)]
  ttl     = 300
}




# Validate the ACM Certificate
resource "aws_acm_certificate_validation" "comet_cert_validation" {
  certificate_arn         = aws_acm_certificate.comet_cert.arn
  validation_record_fqdns = [aws_route53_record.comet_cert_validation.fqdn]
}
