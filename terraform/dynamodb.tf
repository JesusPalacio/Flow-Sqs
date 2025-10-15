resource "aws_dynamodb_table" "payment" {
  name         = var.payment_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "traceId"

  attribute {
    name = "traceId"
    type = "S"
  }

  tags = {
    Name = "payment"
    Service = "flow-service"
  }
}