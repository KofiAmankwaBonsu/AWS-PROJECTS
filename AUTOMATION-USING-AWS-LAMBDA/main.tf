module "ec2" {
  source = "./modules/EC2"

  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  instance_type = var.instance_type
  environment   = var.environment
}

module "lambda" {
  source = "./modules/LAMBDA"

  environment = var.environment
  instance_id = module.ec2.instance_id

  lambda_functions = {
    "start-instances" = {
      filename    = "start_instances.zip"
      handler     = "index.handler"
      runtime     = "python3.9"
      memory_size = 128
      timeout     = 30
      environment_variables = {
        OPERATION = "START"
      }
    },
    "stop-instances" = {
      filename    = "stop_instances.zip"
      handler     = "index.handler"
      runtime     = "python3.9"
      memory_size = 128
      timeout     = 30
      environment_variables = {
        OPERATION = "STOP"
      }
    },
    "backup-instances" = {
      filename    = "backup_instances.zip"
      handler     = "index.handler"
      runtime     = "python3.9"
      memory_size = 256
      timeout     = 60
      environment_variables = {
        BACKUP_RETENTION = "7"
      }
    }
  }
}

module "monitoring" {
  source = "./modules/MONITORING"

  instance_id          = module.ec2.instance_id
  lambda_function_ids  = module.lambda.lambda_function_ids
  lambda_function_name = module.lambda.function_names
  environment          = var.environment
  aws_region           = var.aws_region
  sns_topic_arn        = module.sns.topic_arns["infra-alerts"]
}

module "scheduling" {
  source = "./modules/SCHEDULING"

  environment = var.environment

  schedules = {
    "start-daily" = {
      description         = "Start instances every weekday morning"
      schedule_expression = var.start_schedule
      lambda_function_arn = module.lambda.function_arns["start-instances"]
      input_parameters = {
        action = "start"
      }
    },
    "stop-daily" = {
      description         = "Stop instances every weekday evening"
      schedule_expression = var.stop_schedule
      lambda_function_arn = module.lambda.function_arns["stop-instances"]
      input_parameters = {
        action = "stop"
      }
    },
    "backup-daily" = {
      description         = "Daily backup of instances"
      schedule_expression = var.backup_schedule
      lambda_function_arn = module.lambda.function_arns["backup-instances"]
      input_parameters = {
        backup_type    = "daily"
        retention_days = 7
      }
    }
  }
}

module "sns" {
  source = "./modules/SNS"

  environment = var.environment

  topics = {
    "infra-alerts" = {
      name        = "system-alerts"
      description = "SNS topic for system and Lambda function alerts"
    }
  }
  subscriptions = {
    "email-notification" = {
      topic_name = "infra-alerts"
      protocol   = "email"
      endpoint   = "yourEmail" # Replace with your email
    },
  }
}
