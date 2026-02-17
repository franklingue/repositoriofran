output "alb_dns_name" {
  value       = aws_lb.app.dns_name
  description = "DNS público del ALB"
}

output "route53_zone_id" {
  value       = aws_route53_zone.primary.zone_id
  description = "ID de la hosted zone"
}

output "certificate_arn" {
  value       = aws_acm_certificate_validation.cert_validation.certificate_arn
  description = "ARN del certificado validado"
}

output "rds_endpoint" {
  value       = aws_db_instance.mysql.address
  description = "Endpoint de la base de datos MySQL"
}
