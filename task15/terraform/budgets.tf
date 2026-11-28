# =============================================================================
# AWS Budgets & Cost Alerting Governance (FinOps Visibility Tier)
# =============================================================================

# 1. SNS Topic for FinOps Cost & Budget Alerts
resource "aws_sns_topic" "budget_alerts" {
  name = "${var.project_name}-budget-alerts"

  tags = {
    Name = "${var.project_name}-budget-alerts"
  }
}

# 2. SNS Topic Policy allowing AWS Budgets to publish alerts
resource "aws_sns_topic_policy" "budget_alerts" {
  arn    = aws_sns_topic.budget_alerts.arn
  policy = data.aws_iam_policy_document.sns_budget_policy.json
}

data "aws_iam_policy_document" "sns_budget_policy" {
  statement {
    sid     = "AllowAWSBudgetsPublish"
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }

    resources = [aws_sns_topic.budget_alerts.arn]
  }
}

# 3. Email Subscription for Real-Time Budget Alert Notifications
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = var.budget_alert_email
}

# 4. AWS Monthly Spend Budget ($50.00 USD Threshold)
resource "aws_budgets_budget" "cost_budget" {
  name              = "${var.project_name}-monthly-cost-budget"
  budget_type       = "COST"
  limit_amount      = var.monthly_budget_limit
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2026-01-01_00:00"

  cost_types {
    include_credit             = false
    include_discount           = true
    include_other_subscription = true
    include_recurring          = true
    include_refund             = false
    include_subscription       = true
    include_support            = true
    include_tax                = true
    include_upfront            = true
    use_blended                = false
  }

  # Alert 1: 80% Actual Spend Threshold
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_alert_email]
    subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
  }

  # Alert 2: 100% Forecasted Spend Threshold
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.budget_alert_email]
    subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
  }

  depends_on = [
    aws_sns_topic_policy.budget_alerts
  ]
}
