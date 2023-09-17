resource "cloudflare_device_posture_rule" "os" {
  account_id = var.cloudflare_account_id
  name       = "Minimum macOS version"
  type       = "os_version"
  schedule   = "5m"

  match {
    platform = "mac"
  }

  input {
    version  = "13.5.2"
    operator = ">="
  }
}
