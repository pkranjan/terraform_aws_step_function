variable "tag_environment" {
    type = string
    description = "Your AWS Environment"
}

variable "name" {
    type = string
    description = "Step Function Name"
}

variable "lambda.arns" {
    type = list(string)
    description = "List of Lambda ARNs"
}
