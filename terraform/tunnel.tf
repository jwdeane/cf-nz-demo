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

#-----------------------------------------------------------
# 5-zt
#-----------------------------------------------------------
# Generates a 35-character secret for the tunnel.
resource "random_id" "tunnel_secret_zt" {
  byte_length = 35
}

resource "cloudflare_tunnel" "warp" {
  account_id = var.cloudflare_account_id
  name       = var.tunnel_name_zt
  secret     = random_id.tunnel_secret_zt.b64_std
  config_src = "cloudflare"
}

resource "cloudflare_tunnel_config" "warp" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.warp.id

  config {
    warp_routing {
      enabled = true
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_tunnel_route" "network-a" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.warp.id
  network    = var.NETWORK_A_CIDR
  comment    = "Network A"
}
