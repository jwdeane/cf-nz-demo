resource "cloudflare_record" "httpbin-tunnel" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = var.tunnel_hostname
  value   = cloudflare_tunnel.this.cname
  type    = "CNAME"
  proxied = true
}
