data "null_data_source" "environment" {
    inputs = {
        environment = "${lower(replace(var.tag_environment,"/[^a-zA-Z0-9]/",""))}"
    }
}

output "environmant" {
    value = "${data.null_data_source.environment.outputs["environment"]}"
}

data "aws_iam_policy_document" "lambda_execution_policy" {
  statement {
    sid = "EnableServiceInvocation"
    actions = ["lambda:InvokeFunction"]
    effect = "Allow"
    resources = var.lambda_arns
  }
}

resource "aws_iam_policy" "lambda_execution_policy" {
    name = "lambda-execution-policy-${var.name}"
    policy = join("", data.aws_iam_policy_document.lambda_execution_policy.*.json)
}

resource "aws_iam_role" "iam_for_sfn_module" {
  name = var.name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:Assumerole",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test_mandatory_sfn" {
    role = aws_iam_role.iam_for_sfn_module.name
    policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = var.name
  role_arn = aws_iam_role.iam_for_sfn_module.arn

  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using an AWS Lambda Function...",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:333463754612:function:run_task",
      "End": true
    }
  }
}
EOF
}
