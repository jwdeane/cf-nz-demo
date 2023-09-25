# https://developers.cloudflare.com/waf/rate-limiting-rules/parameters/#rate-limiting-parameters
resource "cloudflare_ruleset" "ratelimit" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = "custom ratelimit rules"
  kind    = "zone"
  phase   = "http_ratelimit"

  # credential stuffing 1
  rules {
    action = "managed_challenge"
    ratelimit {
      characteristics = [
        "cf.colo.id",
        "ip.src"
      ]
      counting_expression = "(http.request.uri.path eq \"/login\" and http.request.method eq \"POST\" and http.response.code in {401 403})"
      period              = 60
      requests_per_period = 4
      requests_to_origin  = true
    }

    expression  = "(http.host contains \"httpbin\" and http.request.uri.path eq \"/login\" and http.request.method eq \"POST\")"
    description = "credential stuffing 1 - challenge"
    enabled     = true
  }

  # credential stuffing 2
  rules {
    action = "managed_challenge"
    ratelimit {
      characteristics = [
        "cf.colo.id",
        "ip.src"
      ]
      counting_expression = "(http.request.uri.path eq \"/login\" and http.request.method eq \"POST\" and http.response.code in {401 403})"
      period              = 600
      requests_per_period = 10
      requests_to_origin  = true
    }

    expression  = "(http.host contains \"httpbin\" and http.request.uri.path eq \"/login\" and http.request.method eq \"POST\")"
    description = "credential stuffing 2 - challenge"
    enabled     = true
  }

  # credential stuffing 3
  rules {
    action = "block"
    ratelimit {
      characteristics = [
        "cf.colo.id",
        "ip.src"
      ]
      counting_expression = "(http.request.uri.path eq \"/login\" and http.request.method eq \"POST\" and http.response.code in {401 403})"
      period              = 3600
      requests_per_period = 20
      requests_to_origin  = true
      mitigation_timeout  = 86400
    }

    expression  = "(http.host contains \"httpbin\")"
    description = "credential stuffing 3 - block"
    enabled     = true
  }

  # challenge bots by 403/404
  rules {
    action = "managed_challenge"
    ratelimit {
      characteristics = [
        "cf.colo.id",
        "ip.src"
      ]
      counting_expression = "(http.response.code in {403 404})"
      period              = 300
      requests_per_period = 5
      requests_to_origin  = true
    }

    expression  = "(http.host contains \"httpbin\")"
    description = "challenge bots returning 403-404"
    enabled     = true
  }

  # ja3 bot
  rules {
    action = "managed_challenge"
    ratelimit {
      characteristics = [
        "cf.colo.id",
        "cf.bot_management.ja3_hash"
      ]
      period              = 60
      requests_per_period = 10
      requests_to_origin  = true
    }

    expression  = "(http.host contains \"httpbin\" and cf.bot_management.score lt 10)"
    description = "challenge bots by JA3"
    enabled     = true
  }
}
