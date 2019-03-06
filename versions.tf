terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "1.60.0-dev20190216h00-dev"
}

provider "random" {
  version = "3.0.0-dev20190216h01-dev"
}

provider "template" {
  version = "2.1.0"
}