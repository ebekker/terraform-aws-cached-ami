
variable "most_recent" {
  default = false
  description = "See `aws_ami.most_recent`."
}

variable "executable_users" {
  default = []
  description = "See `aws_ami.most_recent`."
}

variable "filters" {
  default = []
  description = <<EOF
See `aws_ami.filter`.
Instead of specifying multiple filter sub-clauses, due to limitations on module input value
types, these have to be specified as an array of objects with `name` and `values` properties.
EOF
}

variable "owners" {
  default = []
  description = "See `aws_ami.owners`."
}

variable "name_regex" {
  default = ""
  description = "See `aws_ami.name_regex`."
}

variable "cache_key" {
  description = "A unique key across the named cache that uniquely identifies this module's resolve value"
}

variable "cache_expires" {
  default = -1
  description = "Time in seconds of how long to cache a value."
}

variable "cache_root" {
  default = "_TMP/amis"
  description = "The path of a cache root directory which will store the cached value."
}
