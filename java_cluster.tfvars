region = "us-east-1"
environment = "dev"
project_name = "app-cluster"

// network

cidr_vpc = "10.0.0.0/16"

subnet_cidr_blocks = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

// eks

instance_mode = "ON_DEMAND"

instance_type = "t3.small"