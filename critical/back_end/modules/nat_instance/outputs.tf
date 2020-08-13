output "eip_public_ip" {
  value = aws_eip.nat_instance.public_ip
}
