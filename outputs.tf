output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = [for subnet in aws_subnet.rosa_private : subnet.id]
}