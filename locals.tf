data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = var.multi_az ? [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2],
  ] : [data.aws_availability_zones.available.names[0]]
}
