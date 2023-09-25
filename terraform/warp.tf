data "cloudflare_access_identity_provider" "github" {
  name       = "GitHub"
  account_id = var.cloudflare_account_id
}

resource "cloudflare_access_group" "nz" {
  account_id = var.cloudflare_account_id
  name       = "NZ-Demo"

  include {
    login_method = [data.cloudflare_access_identity_provider.github.id]
  }
}

# resource "cloudflare_device_settings_policy" "this" {
#   account_id            = var.cloudflare_account_id
#   name                  = "NZ-Demo"
#   description           = "NZ Demo policy"
#   precedence            = 10
#   match                 = "identity.email in {\"25thhour@gmail.com\"}"
#   default               = false
#   enabled               = true
#   allow_mode_switch     = true
#   allow_updates         = true
#   allowed_to_leave      = true
#   auto_connect          = 0
#   disable_auto_fallback = true
#   support_url           = "https://www.cloudflare.com"
#   switch_locked         = false
#   service_mode_v2_mode  = "warp"
#   exclude_office_ips    = false
# }

# Default exclude list with 10.0.0.0/8 removed
resource "cloudflare_split_tunnel" "exclude" {
  account_id = var.cloudflare_account_id
  mode       = "exclude"
  tunnels {
    address = "100.64.0.0/10"
  }
  tunnels {
    address     = "169.254.0.0/16"
    description = "DHCP Unspecified"
  }
  tunnels {
    address = "172.16.0.0/12"
  }
  tunnels {
    address = "192.0.0.0/24"
  }
  tunnels {
    address = "192.168.0.0/16"
  }
  tunnels {
    address = "224.0.0.0/24"
  }
  tunnels {
    address = "240.0.0.0/4"
  }
  tunnels {
    address     = "255.255.255.255/32"
    description = "DHCP Broadcast"
  }
  tunnels {
    address     = "fe80::/10"
    description = "IPv6 Link Local"
  }
  tunnels {
    address = "fd00::/8"
  }
  tunnels {
    address = "ff01::/16"
  }
  tunnels {
    address = "ff02::/16"
  }
  tunnels {
    address = "ff03::/16"
  }
  tunnels {
    address = "ff04::/16"
  }
  tunnels {
    address = "ff05::/16"
  }
}
