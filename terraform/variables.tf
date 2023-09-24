#-----------------------------------------------------------
# Cloudflare
#-----------------------------------------------------------
variable "cloudflare_account_id" {
  default = "1264dd6e6cc190c7c7527289dd3aa799"
}
variable "cloudflare_zone" {
  default = "cflr.one"
}
variable "tunnel_name" {
  default = "nz-demo"
}
variable "tunnel_hostname" {
  default = "httpbin-tunnel"
}

#-----------------------------------------------------------
# Digital Ocean
#-----------------------------------------------------------
variable "do_cloudflare_firewall_name" {
  default     = "cloudflare-ips"
  description = "Digital Ocean firewall allowing Cloudflare IPs"
}
variable "do_ssh_firewall_name" {
  default     = "ssh-all"
  description = "Digital Ocean firewall allowing SSH"
}
variable "digitalocean_ssh_key_name" {
  default = "t1ny"
}
variable "digitalocean_image" {
  default = "ubuntu-22-04-x64"
}
variable "digitalocean_region" {
  default = "syd1"
}
variable "digitalocean_size" {
  default = "s-1vcpu-1gb"
}
variable "droplet_name" {
  default = "1-certificates"
}
variable "droplet_name_tunnel" {
  default = "2-tunnel"
}

#-----------------------------------------------------------
# 5-zt
#-----------------------------------------------------------
variable "team_name" {
  default = "cflr"
}
variable "block_page_logo_url" {
  default = "https://r2.jwdn.cc/jp-nedry.gif"
}
variable "tunnel_name_zt" {
  default = "warp-to-tunnel"
}
variable "droplet_name_zt" {
  default = "5-zt"
}
variable "MYSQL_ROOT_PASSWORD" {
  sensitive = true
}
variable "MYSQL_PASSWORD" {
  sensitive = true
}
variable "MYSQL_USER" {}
variable "NETWORK_A_CIDR" {
  default = "10.1.0.0/20"
}
variable "WP_INTERNAL_IP" {
  default = "10.1.1.10"
}
