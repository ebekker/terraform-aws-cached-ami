# README - Terraform Module:  `aws-cached-ami`

Implements a cacheable version of the aws_ami data source.  Since the aws_ami data source typically
takes a long time to query and resolve for the AMI based on input properties, and the fact that the
resolved image ID does not frequently change, using this version typically returns the expected
value but performs better.

Under the hood, the module relies on a couple of helper scripts that actually manage the cache
entries.  In this version, theses scripts are implemented as PowerShell Core scripts, so they
should work anywhere that PWSH runs (Win, Linux, MacOS) however only Windows has been tested
at this time.

You can however substitute your own scripts for the two helper scripts as long as the
semantics and interface is preserved.

## Inputs

The `cached-ami` module re-exposes all the same inputs as the native `aws_ami` data
source that it wraps, with the same behavior.  The one exception is the `filter` parameter
of the original data source, which can be configured using multiple `filter` clauses.
Because of limitations of the types supported by variables, the original filter input
is replaced with a `filters` (notice the `s`) parameter, which is an array of objects,
each object having a `name` and `values` property, similar to the original form.

So for example, where you would specify this with the `aws_ami` data source:

```hcl
resource "aws_ami" "ami_win2016base" {
  most_recent      = true
  owners           = ["amazon"]

  name_regex = "Windows_Server-2016-English-Full-Base"

  ## For ref of possible filters:
  ##    https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html

  filter {
    name   = "platform"
    values = ["windows"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
```

With the `aws_cacheable_ami` module you would specify it like so:

```hcl
module "ami_win2016base" {
  source    = "path/to/module"
  cache_key = "ami_win2016base"

  most_recent = true
  owners      = ["amazon"]

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
```

## Outputs

While possible to reproduce all the same outputs as the original `aws_ami` data source,
this module only exposes the three (3) most common and arguably most useful outputs of
the underlying data source:

* `image_id`
* `name`
* `creation_date`

Other outputs can be added as needed.
