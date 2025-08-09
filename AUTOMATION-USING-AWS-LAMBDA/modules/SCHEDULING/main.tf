resource "aws_cloudwatch_event_rule" "schedules" {
  for_each = var.schedules

  name                = "${var.environment}-${each.key}"
  description         = each.value.description
  schedule_expression = each.value.schedule_expression

  tags = {
    Environment = var.environment
    Schedule    = each.key
  }
}

resource "aws_cloudwatch_event_target" "lambda_targets" {
  for_each = var.schedules

  rule      = aws_cloudwatch_event_rule.schedules[each.key].name
  target_id = "${each.key}-target"
  arn       = each.value.lambda_function_arn

  input = jsonencode(each.value.input_parameters)
}

resource "aws_lambda_permission" "allow_eventbridge" {
  for_each = var.schedules

  statement_id  = "AllowEventBridge-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedules[each.key].arn
}
