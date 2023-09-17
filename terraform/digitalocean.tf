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
