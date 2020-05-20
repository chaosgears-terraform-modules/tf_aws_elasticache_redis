module "security_group" {
  source = "git@github.com:chaosgears-terraform-modules/terraform-aws-security-group.git//?ref=v3.4.2"

  name = var.sg_name

  description = "Security group for example usage with EC2 instance"
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule = "redis-tcp"
      cidr_blocks = var.allowed_cidr[0]
    },
    {
      rule = "redis-tcp"
      cidr_blocks = var.allowed_cidr[1]
    }
  ]
  egress_with_cidr_blocks = [
    {
      rule = "all-all"
    }
  ]

  tags = var.tags

}
