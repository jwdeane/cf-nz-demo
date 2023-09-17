terraform {
  backend "s3" {
    bucket = "tfstate"
    key    = "nz-demo/terraform.tfstate"

    region                      = "auto"
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_credentials_validation = true
    force_path_style            = true

    # endpoint = set AWS_S3_ENDPOINT env var
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.14.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.30.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}
