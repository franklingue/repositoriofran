# Certificado para www.mercadoecuador.com.ec y el apex
resource "aws_acm_certificate" "cert" {
  domain_name               = "${var.subdomain}.${var.domain_name}"
  validation_method         = "DNS"
  subject_alternative_names = [var.domain_name]

  tags = { Name = "${var.project_name}-cert" }
}

# Hosted zone pública para el dominio
resource "aws_route53_zone" "primary" {
  name = var.domain_name
  tags = { Name = "${var.project_name}-zone" }
}

# Registros de validación DNS ACM (www y apex)
resource "aws_route53_record" "cert_validation_www" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
  zone_id = aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation_www : r.fqdn]
}
