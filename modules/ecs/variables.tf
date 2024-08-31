variable "project_pre" {
  type = string
}

variable "ecr_uri" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "subnet_ids" {
  type = list
}

variable "blue_tag_arn" {
  type = string
}

variable "green_tag_arn" {
  type = string
}