// main ///////////////////////

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "domain_name" {
  type    = string
  default = "httpbin-ft.etvnet.com"
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "service_count" {
  type    = number
  default = 2
}

// network ///////////////////
variable "aws_network_name" {
  type    = string
  default = "testnet"
}

variable "vpc_cidr_block" {
  type    = string
  default = "172.31.0.0/16"
}

variable "default_network_cidr_a" {
  type    = string
  default = "172.31.80.0/20"
}

variable "default_network_cidr_b" {
  type    = string
  default = "172.31.16.0/20"
}

// logs //////////////////////

variable "retention_in_days" {
  type    = number
  default = 7
}
