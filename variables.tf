variable "vpccidr" {
  type        = string
  description = "VPC CIDR"
}

variable "publicsubnetscidrs" {
  type        = list(string)
  description = "Public Subnets CIDR's"
}

variable "privatesubnetscidrs" {
  type        = list(string)
  description = "Private Subnets CIDR's"
}

variable "commontags" {
  type        = map(string)
  description = "Common Tags"
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable dns support either true or false"
}

variable "availability_zones" {
  type        = list(string)
  description = "Name of the AZ's"
}

variable "security_group_name" {
    type = string
    description = "Security Group Name"
}

variable "security_group_description" {
    type = string
    description = "Security Group Description"
}

variable "security_group_inbound_rules" {
    type = list(object({
      from_port = number
      to_port = number
      protocol = string
      description = string
      cidr_blocks = list(string)
    }))
    description = "Security Group Inbound Rules"
}

variable "sg_tags" {
    type = map(string)
    description = "Tags for Security Group "
}
