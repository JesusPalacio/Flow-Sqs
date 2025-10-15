variable "aws_region" {
  default = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
}

variable "notification_queue_url" {
  description = "SQS Queue URL for notifications"
  type        = string
}

variable "payment_table_name" {
  default     = "payment"
  description = "Name of the DynamoDB payment table"
}
