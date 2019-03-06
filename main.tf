resource "random_pet" "server" {
  count = 5
}

# first-class expressions
output "first_class_pets" {
  value = random_pet.server.*.id
}

# for loop
output "loopy_pets" {
  value = [
    for pet in random_pet.server :
    pet.id
  ]
}

# generalized splat
variable "vehicles" {
  type = "list"
  default = [
    { pilot = "rick", type = "spaceship" },
    { pilot = "burt", type = "automobile" },
    { pilot = "han", type = "spaceship" },
  ]
}

# conditional list
output "spaceship_pilots" {
  value = [
    for v in var.vehicles :
    v.pilot if v.type == "spaceship"
  ]
}

# dynamic blocks
variable "consul_ports" {
  type = "list"
  default = [
    { port = 8300, tcp_allowed = true, udp_allowed = false, description = "Port used by servers to handle incoming requests from other agents" },
    { port = 8301, tcp_allowed = true, udp_allowed = true, description = "Port used to handle gossip in the LAN. Required by all agents" },
    { port = 8302, tcp_allowed = true, udp_allowed = true, description = "Port used by servers to gossip over the WAN, to other servers" },
  ]
}

resource "aws_security_group" "consul" {
  name        = "consul-dynamic-tag-test"
  description = "Some of the rules for a Consul node"

  # UDP rules
  dynamic "ingress" {
    for_each = [
      for port in var.consul_ports :
      port if port.udp_allowed
    ]

    content {
      self        = true
      protocol    = "udp"
      from_port   = lookup(ingress.value, "port", null)
      to_port     = lookup(ingress.value, "port", null)
      description = lookup(ingress.value, "description", null)
    }
  }

  # TCP rules
  dynamic "ingress" {
    for_each = [
      for port in var.consul_ports :
      port if port.tcp_allowed
    ]

    content {
      self        = true
      protocol    = "tcp"
      from_port   = lookup(ingress.value, "port", null)
      to_port     = lookup(ingress.value, "port", null)
      description = lookup(ingress.value, "description", null)
    }
  }
}

# Rich-type module input
module "consul_security_group" {
  source      = "./modules/aws_security_group"
  name        = "rich-type-module-input-test"
  description = "Another Consul security group"

  ingress_rules = {
    agent = {
      from_port = 8300,
      to_port   = 8300,
      protocols = ["tcp"]
    },
    serf_lan = {
      from_port = 8301,
      to_port   = 8301,
      protocols = ["tcp", "udp"]
    },
    serf_wan = {
      from_port = 8302,
      to_port   = 8302,
      protocols = ["tcp", "udp"]
    },
  }
}

# Output attribute from module resource
output "security_group_arn" {
  value = module.consul_security_group.security_group.arn
}

# Template syntax
data "template_file" "pets" {
  template = <<EOF
servers:
%{for pet in random_pet.server~}
  %{if substr(pet.id, 0, 1) == "c"~}
  ${pet.id}.node.consul:443
  %{endif~}
%{endfor}
  EOF
}

output "pets_template" {
  value = data.template_file.pets.rendered
}
