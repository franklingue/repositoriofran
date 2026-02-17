# Infraestructura Terraform para marketplace PHP + MySQL en AWS con Nuvei

## Requisitos
- Terraform >= 1.6
- Cuenta AWS con permisos para: VPC, EC2, ASG, ALB, RDS, Route 53, ACM, Secrets Manager, IAM
- Dominio `mercadoecuador.com.ec` administrado en Route 53 (o acceso para delegar NS a Route 53)
- Key pair en AWS si deseas acceso SSH a las instancias (opcional)

## Componentes
- VPC multi-AZ, subnets públicas/privadas, NAT Gateway
- ALB con HTTPS (ACM) y redirección HTTP→HTTPS
- Auto Scaling Group con Amazon Linux 2023, Nginx + PHP-FPM
- RDS MySQL 8 con backups
- Hosted Zone pública para `mercadoecuador.com.ec` y registros `A/AAAA` para `@` y `www`
- Secrets Manager para credenciales de Nuvei y DB
- IAM para EC2 con permisos mínimos para leer secretos y escribir logs

## Pasos
1. Copia estos archivos en tu repo.
2. Crea/ajusta `terraform.tfvars` a tus valores reales:
   - `region`, tamaños del ASG, tipos de instancia
   - `domain_name` = `mercadoecuador.com.ec` (no incluyas `https://`)
   - `key_name` si quieres SSH
3. (Opcional) Si tu dominio está en otro registrador, crea/actualiza los registros `NS` del dominio para apuntar a los name servers de la hosted zone creada por Terraform (ver salida `route53_zone_id` y consola de Route 53 para NS).
4. Inicializa y despliega:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
5. Terraform creará:
   - Hosted Zone y validará el certificado ACM por DNS.
   - ALB público en `alb_dns_name` y registros `A/AAAA` para `mercadoecuador.com.ec` y `www.mercadoecuador.com.ec`.
6. Completa los secretos de Nuvei:
   - Cambia los placeholders del secreto `nuvei/credentials` (merchantId, terminalId, secretKey, baseUrl) en `secrets.tf` o actualiza con AWS CLI:
     ```bash
     aws secretsmanager put-secret-value \
       --secret-id nuvei/credentials \
       --secret-string '{"merchantId":"M_ID","terminalId":"T_ID","secretKey":"S_KEY","baseUrl":"https://gateway.nuvei.com/"}'
     ```
7. Verifica:
   - Accede a `https://www.mercadoecuador.com.ec` (puede tardar unos minutos).
   - `https://www.mercadoecuador.com.ec/health` debe responder `OK`.
   - `index.php` mostrará estado de conexión MySQL y lectura de variables.

## Notas de seguridad y producción
- Cambia `db_instance_class`, storage y política de backups según carga.
- Considera habilitar `deletion_protection` en RDS y snapshots finales en producción.
- Agrega WAF frente al ALB para endurecer seguridad.
- Se recomienda CloudFront + ACM en `us-east-1` para CDN; no incluido aquí por simplicidad.
- Usa Systems Manager Session Manager para acceso seguro en lugar de SSH.
- No guardes credenciales reales en código; usa Secrets Manager.

## Integración Nuvei (aplicación)
- Este Terraform solo gestiona secretos y permisos. La integración con Nuvei se hace en el código PHP (SDK/API de Nuvei).
- En tu app, lee `NUVEI_*` del fichero `/etc/app.env` o de variables de entorno y utiliza el SDK de Nuvei para crear pagos, manejar callbacks, etc.

## Limpieza
```bash
terraform destroy
```
