resource "cloudflare_record" "pages" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = var.pages_subdomain
  type    = "CNAME"
  value   = "${var.pages_project_name}.pages.dev"
  proxied = true
}

resource "cloudflare_pages_domain" "this" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.this.name
  domain       = "${var.pages_subdomain}.${var.cloudflare_zone}"
  depends_on   = [cloudflare_record.pages]
}

resource "cloudflare_pages_project" "this" {
  account_id        = var.cloudflare_account_id
  name              = var.pages_project_name
  production_branch = "main"

  build_config {
    build_command   = "npm run build"
    destination_dir = var.pages_destination_dir
    root_dir        = var.pages_root_dir
  }

  source {
    type = "github"
    config {
      owner                         = var.pages_repo_owner
      repo_name                     = var.pages_repo_name
      production_branch             = "main"
      pr_comments_enabled           = true
      deployments_enabled           = true
      preview_branch_includes       = ["*"]
      production_deployment_enabled = true
    }
  }
}
