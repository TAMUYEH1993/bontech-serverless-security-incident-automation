resource "aws_dynamodb_table" "security_incidents" {
  name         = "BonTech-Security-Incidents-Terraform"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "incident_id"

  attribute {
    name = "incident_id"
    type = "S"
  }

  tags = {
    ManagedBy = "Terraform"
    Project   = "BonTech-Serverless-Security"
  }
}
