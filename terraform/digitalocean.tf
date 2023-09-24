data "cloudflare_ip_ranges" "cfips" {}

locals {
  cfips = concat(data.cloudflare_ip_ranges.cfips.ipv4_cidr_blocks, data.cloudflare_ip_ranges.cfips.ipv6_cidr_blocks)
}

resource "digitalocean_firewall" "ssh" {
  name        = var.do_ssh_firewall_name
  droplet_ids = [digitalocean_droplet.this.id, digitalocean_droplet.tunnel.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_firewall" "cfips" {
  name        = var.do_cloudflare_firewall_name
  droplet_ids = [digitalocean_droplet.this.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = local.cfips
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = local.cfips
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

#-----------------------------------------------------------
# 1-certificates and 2-tunnel
#-----------------------------------------------------------

data "digitalocean_ssh_key" "this" {
  name = var.digitalocean_ssh_key_name
}

locals {
  caddyb64 = base64encode(templatefile("Caddyfile", {
    ZONE = var.cloudflare_zone
  }))
  composeb64 = base64encode(file("docker-compose.yaml"))
  cert       = base64encode(cloudflare_origin_ca_certificate.origin.certificate)
  key        = base64encode(tls_private_key.this.private_key_pem)
  tunnel_composeb64 = base64encode(templatefile("tunnel-compose.yaml", {
    TUNNEL_TOKEN = cloudflare_tunnel.this.tunnel_token
  }))
}

# proxied with origin certificate
resource "cloudflare_record" "httpbin" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = "httpbin"
  value   = digitalocean_droplet.this.ipv4_address
  type    = "A"
  proxied = true
}

# unproxied - direct to origin
resource "cloudflare_record" "httpbin-direct" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = "httpbin-direct"
  value   = digitalocean_droplet.this.ipv4_address
  type    = "A"
  proxied = false
}

resource "digitalocean_droplet" "this" {
  name       = var.droplet_name
  image      = var.digitalocean_image
  region     = var.digitalocean_region
  size       = var.digitalocean_size
  monitoring = true
  user_data = templatefile("cloud-config.yaml.tpl", {
    CADDYFILE = local.caddyb64
    COMPOSE   = local.composeb64
    CERT      = local.cert
    KEY       = local.key
  })
  ssh_keys = [data.digitalocean_ssh_key.this.id]
  tags     = ["nz-demo"]
}

# Origin Certificate
resource "tls_private_key" "this" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "this" {
  private_key_pem = tls_private_key.this.private_key_pem
}

resource "cloudflare_origin_ca_certificate" "origin" {
  csr                = tls_cert_request.this.cert_request_pem
  hostnames          = ["httpbin.${var.cloudflare_zone}"]
  request_type       = "origin-ecc"
  requested_validity = 5475
}

# egress only via tunnel
resource "digitalocean_droplet" "tunnel" {
  depends_on = [cloudflare_tunnel.this]
  name       = var.droplet_name_tunnel
  image      = var.digitalocean_image
  region     = var.digitalocean_region
  size       = var.digitalocean_size
  monitoring = true
  user_data = templatefile("tunnel-cloud-config.yaml.tpl", {
    COMPOSE = local.tunnel_composeb64
  })
  ssh_keys = [data.digitalocean_ssh_key.this.id]
  tags     = ["nz-demo"]
}

#-----------------------------------------------------------
# 5-zt
#-----------------------------------------------------------
locals {
  warp_composeb64 = base64encode(templatefile("zt-docker-compose.yaml", {
    TUNNEL_TOKEN        = cloudflare_tunnel.warp.tunnel_token
    MYSQL_ROOT_PASSWORD = var.MYSQL_ROOT_PASSWORD
    MYSQL_USER          = var.MYSQL_USER
    MYSQL_PASSWORD      = var.MYSQL_PASSWORD
    NETWORK_A_CIDR      = var.NETWORK_A_CIDR
    WP_INTERNAL_IP      = var.WP_INTERNAL_IP
  }))
}

resource "digitalocean_droplet" "warp_to_tunnel" {
  depends_on = [cloudflare_tunnel.warp]
  name       = var.droplet_name_zt
  image      = var.digitalocean_image
  region     = var.digitalocean_region
  size       = var.digitalocean_size
  monitoring = true
  user_data = templatefile("zt-cloud-config.yaml.tpl", {
    COMPOSE = local.warp_composeb64
  })
  ssh_keys = [data.digitalocean_ssh_key.this.id]
  tags     = ["nz-demo"]
}
