variable "tier_name" {
    description = "the resources attached"
    type = string
}

variable "security_group_id" {
    description = "Security group ID"
    type = string
}

variable "aws_region" {
    description = "my aws region"
    type = string
}

variable "resource_tags" {
    description = "value"
    type = map(string) 
}

variable "vpc_id" {
    description = "VPC ID"
    type = string
}

variable "subnets_ids" {
    description = "public subnets ids"
    type = list(string)
}

variable "desired_capacity" {
    description = "desired capacity of the instances"
    type = number 
}

variable "max_size" {
    description = "maximim number of instances"
    type = number
}

variable "min_size" {
    description = "minimum number of instances"
    type = number
}

variable "user_data_file" {
    description = "file path for the user data"
    type = string
    default = "frontend.sh"
}

variable "internal_lb" {
    description = "An internal load balancer routes requests from clients to targets using private IP addresses."
    type = bool
}

