provider "aws" {
  region  = "eu-west-1"
  version = ">= 2.32.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket = "wescale-slavayssiere-terraform"
    region = "eu-west-1"
    key    = "eks-test/component_web"
  }
}

data "terraform_remote_state" "component_base" {
  backend   = "s3"
  workspace = var.workspace-network

  config = {
    bucket = var.bucket_component_state
    region = "eu-west-1"
    key    = "eks-test/component_base"
  }
}

data "terraform_remote_state" "component_network" {
  backend   = "s3"
  workspace = "${var.workspace-network}"

  config = {
    bucket = var.bucket_component_state
    region = "eu-west-1"
    key    = "eks-test/component_network"
  }
}


data "terraform_remote_state" "component_bastion" {
  backend   = "s3"
  workspace = "${var.workspace-network}"

  config = {
    bucket = var.bucket_component_state
    region = "eu-west-1"
    key    = "eks-test/component_bastion"
  }
}

variable "bucket_component_state" {
}

variable "workspace-network" {
}

variable "ami-name" {
  type = string
}

variable "ami-account" {
  type = string
}

variable "dns-name" {
  type = string
}

variable "user-data" {
  default = ""
}

variable "port" {
  default = "80"
}

variable "health_check" {
  default = "/"
}

variable "health_check_port" {
  default = "80"
}

variable "efs_enable" {
  type = bool
  default = false
}

variable "node-count" {
  type = number
  default = 3
}

variable "max-node-count" {
  type = number
  default = 6
}
variable "min-node-count" {
  type = number
  default = 3
}

variable "attach_cw_ro" {
  type = bool
  default = false
}

variable "bastion_enable" {
  type = bool
  default = false
}
