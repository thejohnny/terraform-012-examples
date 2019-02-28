resource "aws_security_group" "main" {
  name        = var.name
  description = var.description

  # UDP rules
  dynamic "ingress" {
    for_each = [
      for rule in var.ingress_rules :
      rule if contains(rule.protocols, "udp")
    ]

    content {
      self        = true
      protocol    = "udp"
      from_port   = lookup(ingress.value, "from_port", null)
      to_port     = lookup(ingress.value, "to_port", null)
      description = lookup(ingress.value, "description", null)
    }
  }

  # TCP rules
  dynamic "ingress" {
    for_each = [
      for rule in var.ingress_rules :
      rule if contains(rule.protocols, "tcp")
    ]

    content {
      self        = true
      protocol    = "tcp"
      from_port   = lookup(ingress.value, "from_port", null)
      to_port     = lookup(ingress.value, "to_port", null)
      description = lookup(ingress.value, "description", null)
    }
  }
}

# Return resource as output
output "security_group" {
  value = aws_security_group.main
}
