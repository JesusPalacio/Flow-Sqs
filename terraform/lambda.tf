resource "aws_lambda_function" "payment_flow" {
  function_name = "payment-flow-handler"
  runtime       = "nodejs20.x"
  handler       = "src/lambdas/payment-flow/index.handler"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "${path.module}/../dist/payment-flow.zip"

  environment {
    variables = {
      PAYMENT_TABLE             = var.payment_table_name
      NOTIFICATION_QUEUE_URL    = var.notification_queue_url
    }
  }

  timeout = 30

  tags = {
    Service = "flow-service"
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/payment-flow-handler"
  retention_in_days = 7
}

resource "aws_lambda_event_source_mapping" "flow_trigger" {
  event_source_arn  = aws_sqs_queue.flow_queue.arn
  function_name     = aws_lambda_function.payment_flow.arn
  batch_size        = 1
  enabled           = true
}