resource "cloudflare_access_application" "bookmark" {
  account_id = var.cloudflare_account_id
  type       = "bookmark"
  name       = "WordPress"
  domain     = "http://${var.WP_INTERNAL_IP}"
  logo_url   = "https://r2.jwdn.cc/wordpress.png"
}
