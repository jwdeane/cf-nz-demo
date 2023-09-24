data "cloudflare_zone" "this" {
  account_id = var.cloudflare_account_id
  name       = var.cloudflare_zone
}

# Base Zone settings
resource "cloudflare_zone_settings_override" "this" {
  zone_id = data.cloudflare_zone.this.zone_id
  settings {
    always_use_https            = "on"
    automatic_https_rewrites    = "on"
    brotli                      = "on"
    early_hints                 = "on"
    h2_prioritization           = "on"
    http3                       = "on"
    image_resizing              = "on"
    ipv6                        = "on"
    min_tls_version             = "1.2"
    opportunistic_encryption    = "on"
    polish                      = "lossless"
    prefetch_preload            = "on"
    sort_query_string_for_cache = "on"
    ssl                         = "strict"
    true_client_ip_header       = "on"
    zero_rtt                    = "on"
  }
}

# Argo Smart Routing
resource "cloudflare_argo" "this" {
  zone_id        = data.cloudflare_zone.this.zone_id
  tiered_caching = "on"
  smart_routing  = "on"
}

# Smart Tiered Cache
resource "cloudflare_tiered_cache" "this" {
  zone_id    = data.cloudflare_zone.this.zone_id
  cache_type = "smart"
}

# Smart Tiered Cache w/ Regional
resource "cloudflare_regional_tiered_cache" "this" {
  zone_id = data.cloudflare_zone.this.zone_id
  value   = "on"
}

# Enable Logpull
# https://developers.cloudflare.com/logs/logpull/enabling-log-retention/
resource "cloudflare_logpull_retention" "this" {
  zone_id = data.cloudflare_zone.this.zone_id
  enabled = true
}

#-----------------------------------------------------------
# 5-zt
#-----------------------------------------------------------
resource "cloudflare_teams_account" "this" {
  account_id           = var.cloudflare_account_id
  tls_decrypt_enabled  = true
  activity_log_enabled = true

  antivirus {
    enabled_download_phase = true
    enabled_upload_phase   = false
    fail_closed            = true
  }

  proxy {
    tcp     = true
    udp     = true
    root_ca = true
  }

  url_browser_isolation_enabled = true

  logging {
    redact_pii = true
    settings_by_rule_type {
      dns {
        log_all    = false
        log_blocks = true
      }
      http {
        log_all    = true
        log_blocks = true
      }
      l4 {
        log_all    = false
        log_blocks = true
      }
    }
  }

  block_page {
    background_color = "#000000"
    enabled          = true
    footer_text      = "Mistakes were made, let's not mention this again."
    header_text      = "BLOCKED"
    logo_path        = var.block_page_logo_url
    name             = var.team_name
  }
}
