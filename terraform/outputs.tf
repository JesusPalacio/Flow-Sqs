output "lambda_name" {
  value = aws_lambda_function.payment_flow.function_name
}

output "dynamodb_table" {
  value = aws_dynamodb_table.payment.name
}

output "lambda_role" {
  value = aws_iam_role.lambda_exec.arn
}