provider "aws" {
  region = var.region
  version = "~> 2.62.0"
  skip_region_validation = true
}

provider "random" {
  version = "~> 2.2"
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "random_id" "salt" {
  byte_length = 8
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = format("${var.name}-redis-${var.env}")
  replication_group_description = "Terraform-managed ElastiCache replication group for ${var.name}-${var.env}"
  number_cache_clusters         = var.redis_clusters
  node_type                     = var.redis_node_type
  automatic_failover_enabled    = var.redis_failover
  engine_version                = var.redis_version
  port                          = var.redis_port
  parameter_group_name          = aws_elasticache_parameter_group.redis_parameter_group.id
  subnet_group_name             = aws_elasticache_subnet_group.redis_subnet_group.id
  security_group_ids            = [module.security_group.this_security_group_id]
  apply_immediately             = var.apply_immediately
  maintenance_window            = var.redis_maintenance_window
  snapshot_window               = var.redis_snapshot_window
  snapshot_retention_limit      = var.redis_snapshot_retention_limit
  tags                          = var.tags
}

resource "aws_elasticache_parameter_group" "redis_parameter_group" {
  name = replace(format("%.255s", lower(replace("${var.name}-${var.env}-${random_id.salt.hex}", "_", "-"))), "/\\s/", "-")

  description = "Terraform-managed ElastiCache parameter group for ${var.name}-${var.env}"

  # Strip the patch version from redis_version var
  family = "redis${replace(var.redis_version, "/\\.[\\d]+$/", "")}"
  dynamic "parameter" {
    for_each = var.redis_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = replace(format("%.255s", lower(replace("${var.name}-${var.env}-${random_id.salt.hex}", "_", "-"))), "/\\s/", "-")
  subnet_ids = var.subnets
}
