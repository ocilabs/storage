variable "default_ad" {
  type    = number
  default = 0
  description ="The block volume Availability domain name (AD1, AD2 or AD3)"
}
variable "default_size_in_gbs" {
  type    = number
  default = 60
  description = "Size of the block volume in GB (integer)"
}