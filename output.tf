#creating output for ec2 public ip
output "set5-instance-public-ip" {
  value = aws_instance.set5-instance.public_ip
}