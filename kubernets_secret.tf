resource "kubernetes_secret" "db_credentials" {
  metadata {
    name = "db-credentials"
  }
  data = {
    DB_HOST = aws_db_instance.rds.address
    DB_USER = "admin"
    DB_PASS = random_password.db.result
    DB_NAME = "appdb"
  }
}

#verify secrets: 
  #kubectl get secret db-credentials -o yaml