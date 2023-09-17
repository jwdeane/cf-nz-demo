# Generates a 35-character secret for the tunnel.
resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "this" {
  account_id = var.cloudflare_account_id
  name       = var.tunnel_name
  secret     = random_id.tunnel_secret.b64_std
  config_src = "cloudflare"
}

resource "cloudflare_tunnel_config" "httpbin" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.this.id

  config {
    ingress_rule {
      hostname = "${var.tunnel_hostname}.${var.cloudflare_zone}"
      service  = "http://httpbin:80"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}
