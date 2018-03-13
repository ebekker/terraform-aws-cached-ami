
module "ami_win2016base" {
  source   = "../../"
  cache_key = "ami_win2016base"

  most_recent      = true
  owners           = ["amazon"]

  name_regex = "Windows_Server-2016-English-Full-Base"

  ## For ref of possible filters:
  ##    https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html

  filters = [
    ,{
      name   = "platform"
      values = ["windows"]
    }

    ,{
      name   = "architecture"
      values = ["x86_64"]
    }

    ,{
      name   = "state"
      values = ["available"]
    }
  ]
}

## Shows the resolved values
output "ami_win2016base" {
  value = <<EOF

  * image_id.......:  ${module.ami_win2016base.image_id}
  * name...........:  ${module.ami_win2016base.name}
  * created........:  ${module.ami_win2016base.creation_date}
  * (is_cached?)...:  ${module.ami_win2016base._is_cached}
EOF
}

module "ami_nat" {
  source    = "../.."
  cache_key = "ami_nat"

  most_recent      = true
  owners = ["amazon"]

  ## For ref of possible filters:
  ##    https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html

  filters = [
    ,{ name   = "name"  values = ["amzn-ami-vpc-nat*"] }
  ]
}

## For debugging
output "ami_nat" {
  value = <<EOF

  * image_id.......:  ${module.ami_nat.image_id}
  * name...........:  ${module.ami_nat.name}
  * created........:  ${module.ami_nat.creation_date}
  * (is_cached?)...:  ${module.ami_nat._is_cached}
EOF
}