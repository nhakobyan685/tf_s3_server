output "instance_ip_addr" {
  value       = aws_instance.webserver.private_ip
  description = "My webserver ip"
}

