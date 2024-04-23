region = "us-east-1"
environment = "dev"
project_name = "utility-cluster"

// network

cidr_vpc = "11.0.0.0/16"

subnet_cidr_blocks = ["11.0.10.0/24", "11.0.11.0/24", "11.0.12.0/24", "11.0.13.0/24"]

// eks

instance_mode = "ON_DEMAND"

instance_type = "t3.small"

// jenkins

jenkins_admin_user = "SENSITIVE VALUE"

jenkins_admin_password = "SENSITIVE VALUE"