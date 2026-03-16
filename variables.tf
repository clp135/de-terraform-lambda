# Name for the source bucket
variable "raw_bucket_name" {
  type    = string
  default = "yurim-ybigta-raw-2026" 
}

# Name for the destination bucket
variable "clean_bucket_name" {
  type    = string
  default = "yurim-ybigta-clean-2026"
}