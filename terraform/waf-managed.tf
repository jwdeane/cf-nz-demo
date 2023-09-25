data "cloudflare_rulesets" "managed_rulesets" {
  zone_id = data.cloudflare_zone.this.id
  filter {
    phase = "http_request_firewall_managed"
  }
}

# grab the OWASP rules as we'll need them to set the `anomaly_score` local.
data "cloudflare_rulesets" "owasp_rules" {
  zone_id = data.cloudflare_zone.this.id
  filter {
    name = "Cloudflare OWASP Core Ruleset"
  }
  include_rules = true
}

locals {
  cloudflare_managed_ruleset = {
    for id, r in data.cloudflare_rulesets.managed_rulesets.rulesets : "id" => r.id
    if r.name == "Cloudflare Managed Ruleset"
  }
  owasp_managed_ruleset = {
    for id, r in data.cloudflare_rulesets.managed_rulesets.rulesets : "id" => r.id
    if r.name == "Cloudflare OWASP Core Ruleset"
  }
  anomaly_score = {
    for id, r in data.cloudflare_rulesets.owasp_rules.rulesets[0].rules : "id" => r.id
    if r.description == "949110: Inbound Anomaly Score Exceeded"
  }
}

resource "cloudflare_ruleset" "zone_level_managed_waf" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = "managed waf"
  kind    = "zone"
  phase   = "http_request_firewall_managed"

  rules {
    action = "execute"
    action_parameters {
      id      = local.cloudflare_managed_ruleset.id
      version = "latest"
    }
    expression  = "true"
    description = "Run Cloudflare Managed Ruleset across all of ${var.cloudflare_zone}"
    enabled     = true
  }

  rules {
    action = "execute"
    action_parameters {
      id      = local.owasp_managed_ruleset.id
      version = "latest"
      overrides {
        categories {
          category = "paranoia-level-3"
          enabled  = false
        }
        categories {
          category = "paranoia-level-4"
          enabled  = false
        }
        rules {
          id              = local.anomaly_score.id
          action          = "log"
          score_threshold = 60
        }
      }
    }
    expression  = "true"
    description = "Run the OWASP Managed Ruleset across all of ${var.cloudflare_zone}"
    enabled     = true
  }
}
