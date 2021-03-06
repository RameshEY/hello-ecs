resource "aws_elasticache_cluster" "default" {
  count                = "${var.redis_cluster_count}"
  cluster_id           = "tf-example-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  port                 = 6379
  num_cache_nodes      = 1
  subnet_group_name = "${aws_elasticache_subnet_group.default.name}"
  security_group_ids = ["${aws_security_group.elasticache_sg.id}"]
}

resource "aws_elasticache_subnet_group" "default" {
  count      = "${var.redis_cluster_count}"
  name       = "tf-test-cache-subnet"
  subnet_ids = ["${aws_subnet.main.*.id}"]
}

resource "aws_security_group" "elasticache_sg" {
  count       = "${var.redis_cluster_count}"
  description = "allow redis from instances"
  vpc_id      = "${aws_vpc.main.id}"
  name        = "elasticache_sg"

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"

    security_groups = [
      "${aws_security_group.instance_sg.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}