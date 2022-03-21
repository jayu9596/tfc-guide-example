provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


locals {
  new_line                = "\"\n"
  quotes                  = "\""
  semi_colon              = ":"
  open_square_bracket     = "["
  close_square_bracket    = "]"
  space                   = " "
  tab                     = "\"\t"

  dormant_user_whitelisted_tenants = tolist([
    "d1",
    "d2"
  ])

  privilege_escalation_whitelisted_tenants = tolist([
    "pe1"
  ])

  impair_defenses_whitelisted_tenants = tolist([
    "i1",
    "i2",
    "i3"
  ])

  persistence_whitelisted_tenants = tolist([
    "p1"
  ])

  experimental_mode_whitelisted_tenants = tomap({
    "experimentalModeWhitelistedTenants" = tomap({
      "DORMANT_USER" = local.dormant_user_whitelisted_tenants,
      "PRIVILEGE_ESCALATION" = local.privilege_escalation_whitelisted_tenants,
      "IMPAIR_DEFENSES" = local.impair_defenses_whitelisted_tenants,
      "PERSISTENCE" = local.persistence_whitelisted_tenants
    })
  })

  #experimental_mode_whitelisted_tenants_new = join("", local.persistence_whitelisted_tenants, local.dormant_user_whitelisted_tenants)



}

resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name                 = var.instance_name
    "Linux Distribution" = "Ubuntu"
    "Content" = jsonencode(local.experimental_mode_whitelisted_tenants)
  }
}
