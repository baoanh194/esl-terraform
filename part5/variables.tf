variable "region" {
  type = string
  default = "us-west-2"
}

variable "project" {
  description = "The project name to use for unique resource naming"
  default     = "rabbitmq"
  type        = string
}

# Amazon Resource Names (ARNs) uniquely identify AWS resources. 
# We require an ARN when you need to specify a resource unambiguously across all of AWS, such as in IAM policies, 
# Amazon Relational Database Service (Amazon RDS) tags, and API calls.
variable "principal_arns" {
  description = "A list of principal arns allowed to assume the IAM role"
  default     = null
  type        = list(string)
}