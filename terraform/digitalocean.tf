data "cloudflare_ip_ranges" "cfips" {}

locals {
  cfips = concat(data.cloudflare_ip_ranges.cfips.ipv4_cidr_blocks, data.cloudflare_ip_ranges.cfips.ipv6_cidr_blocks)
}

resource "digitalocean_reserved_ip" "syd1" {
  region = "syd1"
}

resource "digitalocean_firewall" "ssh" {
  name = var.do_ssh_firewall_name

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
  name = var.do_cloudflare_firewall_name

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

output "reserved_ip" {
  value = digitalocean_reserved_ip.syd1.ip_address
}

#-----------------------------------------------------------
# 1-certificates
#-----------------------------------------------------------

data "digitalocean_ssh_key" "this" {
  name = var.digitalocean_ssh_key_name
}

locals {
  caddyb64   = base64encode(file("Caddyfile"))
  composeb64 = base64encode(file("docker-compose.yaml"))
  cert       = base64encode(cloudflare_origin_ca_certificate.origin.certificate)
  key        = base64encode(tls_private_key.cflr.private_key_pem)
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

resource "digitalocean_reserved_ip_assignment" "this" {
  ip_address = digitalocean_reserved_ip.syd1.ip_address
  droplet_id = digitalocean_droplet.this.id
}

# Origin Certificate
resource "tls_private_key" "cflr" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "cflr" {
  private_key_pem = tls_private_key.cflr.private_key_pem
}

resource "cloudflare_origin_ca_certificate" "origin" {
  csr                = tls_cert_request.cflr.cert_request_pem
  hostnames          = ["httpbin.${var.cloudflare_zone}"]
  request_type       = "origin-ecc"
  requested_validity = 5475
}

output "ipv4" {
  value = digitalocean_droplet.this.ipv4_address
}
