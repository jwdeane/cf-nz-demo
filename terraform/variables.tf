#-----------------------------------------------------------
# Cloudflare
#-----------------------------------------------------------
variable "cloudflare_account_id" {
  default = "1264dd6e6cc190c7c7527289dd3aa799"
}
variable "cloudflare_zone" {
  default = "cflr.one"
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
