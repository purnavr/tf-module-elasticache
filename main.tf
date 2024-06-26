resource "aws_elasticache_cluster" "elasticache" {
  cluster_id           = "${var.env}-elasticache"
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  engine_version       = var.engine_version
  port                 = var.port
  subnet_group_name = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.main.id]

  tags = merge(
    var.tags,
    { Name = "${var.env}-elasticache" }
  )

}

resource "aws_security_group" "main" {
  name        = "elasticache-${var.env}"
  description = "elasticache-${var.env}"
  vpc_id      = var.vpc_id

  ingress {
    description = "ELASTICACHE"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = var.allow_subnets
  }

  tags = merge(
    var.tags,
    { Name = "elasticache-${var.env}" }
  )
}


#resource "aws_vpc_security_group_ingress_rule" "ingress2" {
#  security_group_id = aws_security_group.main.id
#  cidr_ipv4         = var.allow_app_to
#  from_port         = var.port
#  ip_protocol       = "tcp"
#  to_port           = var.port
#  description = "APP"
#}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.env}-elasticache"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    { Name = "${var.env}-subnet-group" }
  )

}

#output "redis" {
#  value = aws_elasticache_cluster.elasticache
#}

resource "aws_ssm_parameter" "elasticache_endpoint" {
  name = "${var.env}.elasticache.endpoint"
  type = "String"
  value = aws_elasticache_cluster.elasticache.cache_nodes[0].address
}

#output "endpoint" {
#  value = aws_ssm_parameter.elasticache_endpoint.value
#}
