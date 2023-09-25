resource "cloudflare_ruleset" "custom" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = "custom firewall rules - account"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  # challenge outsiders
  rules {
    action      = "managed_challenge"
    expression  = "(not ip.geoip.country in {\"NZ\"} and not cf.bot_management.verified_bot)"
    description = "challenge outsiders"
  }
  # block bots
  rules {
    action      = "block"
    expression  = "(cf.bot_management.score lt 30 and not cf.bot_management.verified_bot)"
    description = "block bots"
  }
  # log by waf score
  rules {
    action      = "log"
    expression  = "(cf.waf.score lt 40)"
    description = "log potential threats"
  }
}
