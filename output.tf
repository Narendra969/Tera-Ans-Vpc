output "publicsubnets_ids" {
    value = aws_subnet.demovpcpublicsubnets[*].id
}

output "sg_id" {
  value = aws_security_group.sg.id
}

output "privatesubnets_ids" {
    value = aws_subnet.demovpcprivatesubnets[*].id
}
