# Secreto Nuvei: completa valores reales antes de aplicar en producción
resource "aws_secretsmanager_secret" "nuvei" {
  name        = var.nuvei_secret_name
  description = "Credenciales Nuvei para el marketplace"
  tags        = { Name = "${var.project_name}-nuvei-secret" }
}

resource "aws_secretsmanager_secret_version" "nuvei_v" {
  secret_id = aws_secretsmanager_secret.nuvei.id
  secret_string = jsonencode({
    merchantId = var.nuvei_merchant_id,
    terminalId = var.nuvei_terminal_id,
    secretKey  = var.nuvei_secret_key,
    baseUrl    = var.nuvei_base_url
  })
}

# Password aleatoria para RDS
resource "random_password" "db_password" {
  length  = 20
  special = true
}

# Secreto DB (endpoint se llena tras crear RDS)
resource "aws_secretsmanager_secret" "db" {
  name        = var.db_secret_name
  description = "Credenciales de conexión a MySQL"
  tags        = { Name = "${var.project_name}-db-secret" }
}

resource "aws_secretsmanager_secret_version" "db_v" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username,
    password = random_password.db_password.result,
    host     = aws_db_instance.mysql.address,
    port     = 3306,
    dbname   = var.db_name
  })
}
