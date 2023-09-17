# DNS
resource "cloudflare_teams_rule" "dns" {
  account_id  = var.cloudflare_account_id
  name        = "Default DNS blocks"
  description = "Block malicious DNS"
  precedence  = 0
  action      = "block"
  filters     = ["dns"]
  traffic     = "any(dns.security_category[*] in {68 178 80 83 176 175 117 131 134 151 153})"
  enabled     = true

  rule_settings {
    block_page_enabled = true
  }
}

# Network: WordPress
resource "cloudflare_teams_rule" "wp_allow" {
  account_id  = var.cloudflare_account_id
  name        = "Allow rule for WP"
  description = "Restrict access to specific users"
  precedence  = 0
  action      = "allow"
  filters     = ["l4"]
  traffic     = "net.dst.ip == ${var.WP_INTERNAL_IP}"
  identity    = "identity.email in {\"25thhour@gmail.com\"}"
  enabled     = true
}
resource "cloudflare_teams_rule" "wp_deny" {
  account_id  = var.cloudflare_account_id
  name        = "Deny rule for WP"
  description = "Deny all"
  precedence  = 1000
  action      = "block"
  filters     = ["l4"]
  traffic     = "net.dst.ip == ${var.WP_INTERNAL_IP}"
  enabled     = true
}

# Do Not Inspect
resource "cloudflare_teams_rule" "dni" {
  account_id  = var.cloudflare_account_id
  name        = "Default DNI"
  description = "DNI managed Application list"
  precedence  = 1000
  action      = "off"
  filters     = ["http"]
  traffic     = "any(app.type.hosts_ids[*] in {16})"
  enabled     = true
}

# Isolate
resource "cloudflare_teams_rule" "isolate" {
  account_id  = var.cloudflare_account_id
  name        = "Isolate Gambling category"
  description = "Isolate and restrict keyboard entry"
  precedence  = 1000
  action      = "isolate"
  filters     = ["http"]
  traffic     = "any(http.request.uri.content_category[*] in {99})"
  enabled     = true

  rule_settings {
    biso_admin_controls {
      disable_keyboard = true
    }
  }
}

# DLP
resource "cloudflare_dlp_profile" "codenames" {
  account_id          = var.cloudflare_account_id
  name                = "Codenames"
  type                = "custom"
  allowed_match_count = 0

  entry {
    enabled = true
    name    = "Classified"
    pattern {
      regex = "badger"
    }
  }
}

resource "cloudflare_teams_rule" "dlp" {
  account_id  = var.cloudflare_account_id
  name        = "Codename DLP"
  description = "Prevent codename leaks"
  precedence  = 1000
  action      = "block"
  filters     = ["http"]
  traffic     = "any(dlp.profiles[*] in {\"${cloudflare_dlp_profile.codenames.id}\"}) and not(any(http.request.domains[*] in {\"r2.cloudflarestorage.com\"}))"
  enabled     = true
}
