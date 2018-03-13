
variable "most_recent" {
  default = false
  description = "See `aws_ami.most_recent`."
}

variable "executable_users" {
  default = []
  description = "See `aws_ami.executable_users`."
}

variable "owners" {
  default = []
  description = "See `aws_ami.owners`."
}

variable "name_regex" {
  default = ""
  description = "See `aws_ami.name_regex`."
}

variable "filters" {
  default = []
  description = <<EOF
See `aws_ami.filter`.
Instead of specifying multiple filter sub-clauses, due to limitations on module input value
types, these have to be specified as an array of objects with `name` and `values` properties.
EOF
}


variable "cache_key" {
  description = <<EOF
A unique key across the named cache root that uniquely identifies this module instance's resolved values.
EOF
}

variable "cache_expires" {
  default = -1
  description = <<EOF
Time in seconds of how long to cache a value.
If unspecifed, defaults to cache expires setting of the supporting tools (currently 12 hours).
EOF
}

variable "cache_root" {
  default = "_TMP/amis"
  description = <<EOF
The path of a cache root directory which will store the cached value.
EOF
}
