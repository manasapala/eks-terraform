variable "aws_region" {
  default = "us-east-1"
}
variable "aws_azs" {
  description = "comma separated string of availability zones in order of precedence"
  default     = "us-east-2a, us-east-2b, us-east-2c"
}
variable "az_count" {
  description = "number of active availability zones in VPC"
  default     = "3"
}
variable "cluster_name" {
  default = "terraform-eks-vgd"
  type    = string
}
#variable "namespaces" {
#  type    = list(string)
#  default = ["CRK-app, Test-app"]
#}