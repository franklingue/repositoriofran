resource "aws_db_subnet_group" "mysql" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags       = { Name = "${var.project_name}-db-subnet-group" }
}

resource "aws_db_instance" "mysql" {
  identifier              = "${var.project_name}-mysql"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.db_password.result
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp3"
  multi_az                = var.db_multi_az
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.mysql.name
  backup_retention_period = 7
  deletion_protection     = false
  skip_final_snapshot     = true

  tags = { Name = "${var.project_name}-mysql" }
}
