terraform {
    ## May work with older versions, but has not been tested
    required_version = ">= 0.11.3"
}

variable "awsProfile" {
    ## Create a profile named "auto@aws" in your local AWS config
    ## or if running from an EC2 instance, rely on IAM rols creds
    default = "auto@aws"
}

variable "awsRegion" {
    default = "us-east-1"
}


## Define provider-level configuration details
## Be sure to define your credential profile -- see TF-NOTES.md for details.
provider "aws" {
    profile = "${var.awsProfile}"
    region  = "${var.awsRegion}"
}
