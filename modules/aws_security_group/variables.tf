variable "name" {
  type        = "string"
  description = "Name of security group"
}

variable "description" {
  type        = "string"
  description = "SO META"
  default     = null
}

variable "ingress_rules" {
  type = map(object({
    from_port = number
    to_port   = number
    protocols = list(string)
  }))

  default = {}
}
