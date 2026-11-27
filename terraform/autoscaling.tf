# =============================================================================
# ECS Autoscaling & Capacity Provider Configurations (FinOps Compute Tier)
# =============================================================================

# 1. ECS Cluster Capacity Providers (Hybrid Fargate + Fargate Spot Strategy)
# Guarantees 1 baseline task on standard Fargate, scales out with 80% Fargate Spot (1:4 ratio)
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 4
    base              = 0
  }
}

# 2. Application Auto Scaling Scalable Target
resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = var.ecs_autoscale_max_capacity
  min_capacity       = var.ecs_autoscale_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# 3. Target Tracking Scaling Policy - CPU Utilization (Target: 70%)
resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "${var.project_name}-cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.ecs_cpu_target_utilization
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# 4. Target Tracking Scaling Policy - Memory Utilization (Target: 80%)
resource "aws_appautoscaling_policy" "ecs_memory" {
  name               = "${var.project_name}-memory-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.ecs_memory_target_utilization
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# 5. Scheduled Action: Off-Peak Scale Down (18:00 UTC daily -> scale to min 1 task)
resource "aws_appautoscaling_scheduled_action" "scale_down_offpeak" {
  name               = "${var.project_name}-scheduled-scale-down"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  schedule           = "cron(0 18 * * ? *)"

  scalable_target_action {
    min_capacity = 1
    max_capacity = 2
  }
}

# 6. Scheduled Action: Business Hours Scale Up (03:00 UTC daily -> scale to 2 tasks)
resource "aws_appautoscaling_scheduled_action" "scale_up_business" {
  name               = "${var.project_name}-scheduled-scale-up"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  schedule           = "cron(0 3 * * ? *)"

  scalable_target_action {
    min_capacity = 2
    max_capacity = 4
  }
}
