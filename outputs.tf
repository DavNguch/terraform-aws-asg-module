output "web_launch_template_id" {
  description = "The ID of the created launch template"
  value       = aws_launch_template.lt.id
}

output "web_dns_name" {
  description = "The ID of the created launch template"
  value       = aws_lb.lb.dns_name
}