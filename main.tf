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
    "ocid1.tenancy.oc1..ewrtdsgfbc",
    "ocid1.tenancy.oc1..werfbasfdd"
  ])

  privilege_escalation_whitelisted_tenants = tolist([
    "ocid1.tenancy.oc1..aergadvaetr"
  ])

  impair_defenses_whitelisted_tenants = tolist([
    "ocid1.tenancy.oc1..sedrydfrv",
    "ocid1.tenancy.oc1..aergdfver",
    "ocid1.tenancy.oc1..saderarsd"
  ])

  persistence_whitelisted_tenants = tolist([
    "ocid1.tenancy.oc1..erydsfgawgsdefrtg"
  ])

  experimental_mode_whitelisted_tenants = tomap({
    "DORMANT_USER" = local.dormant_user_whitelisted_tenants
    "PRIVILEGE_ESCALATION" = local.privilege_escalation_whitelisted_tenants
    "IMPAIR_DEFENSES" = local.impair_defenses_whitelisted_tenants
    "PERSISTENCE" = local.persistence_whitelisted_tenants
  })

  experimental_mode_whitelisted_tenants_new = join("", local.impair_defenses_whitelisted_tenants)

  # experimental_mode_whitelisted_tenants_json = jsondecode(local.experimental_mode_whitelisted_tenants)



}

resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name                 = var.instance_name
    "Linux Distribution" = "Ubuntu"
    "Content" = tostring(local.experimental_mode_whitelisted_tenants_new)
  }
}
