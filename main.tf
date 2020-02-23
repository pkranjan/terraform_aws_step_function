data "null_data_source" "environment" {
    inputs = {
        environment = "${lower(replace(var.tag_environment,"/[^a-zA-Z0-9]/",""))}"
    }
}

output "environmant" {
    value = "${data.null_data_source.environment.outputs["environment"]}"
}

data "aws_iam_policy_document" "sfn_assume_role_policy_document_module" {

  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "states.us-east-1.amazonaws.com",
        "events.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "iam_for_sfn_module" {
  name = "tf-${terraform.workspace}-iam_for_sfn"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role_policy_document_module.json
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "my-state-machine-module"
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
