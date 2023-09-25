# NZ Demo 2023 <!-- omit from toc -->

## Prerequisites

1. An active zone on Cloudflare, assume [Full setup](https://developers.cloudflare.com/dns/zone-setups/full-setup/).
2. An active R2 subscription with a bucket named `tfstate` and an [R2 token generated](https://developers.cloudflare.com/r2/api/s3/tokens/).
3. A Zero Trust subscription.
4. A Digital Ocean (DO) account for compute.
   - **Note**, DO can be swapped out for any compute platform (AWS, Azure, GCP, Raspberry Pi) by replacing [digitalocean.tf](./terraform/digitalocean.tf), updating [providers.tf](./terraform/providers.tf), and updating any [variables.tf](./terraform/variables.tf).

### Required Cloudflare Features

An Enterprise subscription is assumed with the following addons:

| Feature                  |
| ------------------------ |
| Access + Gateway         |
| Advanced Rate Limiting   |
| API Shield               |
| Bot Management           |
| Data Loss Prevention     |
| Remote Browser Isolation |

## Getting Started

> tldr; `brew install doctl dog just sslscan terraform`

As built, this project was tested on [Terraform](https://www.terraform.io) `v1.5.7` and uses [Digital Ocean](https://www.digitalocean.com) for compute.

A `brew install terraform` will install the latest version of Terraform, whilst `brew install doctl` will install the [Digital Ocean cli tool](https://docs.digitalocean.com/reference/doctl/).

### Optional Tools

A number of cli applications are used for quality of life purposes, driven by [`just`](https://just.systems). All can be ignored if you choose not to use the `Justfile` recipes.

- [`just`](https://just.systems) as a `Make` alternative for running recipes.
- [`sslscan`](https://github.com/rbsec/sslscan) to scan a hosts ssl certificate.
- [`dog`](https://github.com/ogham/dog) a DNS client (think `dig`) with clean output for demo purposes.

Run `brew install dog just sslscan` to install.

**Note:** this repository has been tested on macOS 13.6 **exclusively**.

## ⚠️ Update variables and secrets

**First** update ALL secrets in [.env.example](./.env.example) and select variables in [variables.tf](./terraform/variables.tf).

At a minimum, you _must_ set new variable values for:

1. `cloudflare_account_id` - replace with your Cloudflare Account ID.
2. `cloudflare_zone` - the zone that you'll be configuring/deploying resources to.
3. `team_name` - your Zero Trust [team name](https://developers.cloudflare.com/cloudflare-one/faq/teams-getting-started-faq/#whats-a-team-domain/team-name).
4. `block_page_logo_url` - a custom logo (typically your organisations logo) for branding block pages.

### A note about Secret Management

In the [.env.example](./.env.example) file, secrets are dynamically injected using the [1Password `op` CLI tool](https://developer.1password.com/docs/cli/secret-references).

## Init and Apply Terraform configuration

```
# generate .env file
just init
source .env

# initialise Terraform
just tf-init

# check the Plan
just tf-plan

# Apply the Plan
just tf-apply
```

## Created Resources

By applying the Terraform configuration in this repository, the following resources will be created:

| System     | What   | Resource                   | Notes |
| ---------- | ------ | -------------------------- | ----- |
| Cloudflare | DNS    | httpbin.example.tld        | …     |
| Cloudflare | DNS    | httpbin-direct.example.tld | …     |
| Cloudflare | DNS    | httpbin-tunnel.example.tld | …     |
| Cloudflare | Tunnel | nz-demo                    | …     |
| Cloudflare | Tunnel | warp-to-tunnel             | …     |

---

## TOC

- [Prerequisites](#prerequisites)
  - [Required Cloudflare Features](#required-cloudflare-features)
- [Getting Started](#getting-started)
  - [Optional Tools](#optional-tools)
- [⚠️ Update variables and secrets](#️-update-variables-and-secrets)
  - [A note about Secret Management](#a-note-about-secret-management)
- [Init and Apply Terraform configuration](#init-and-apply-terraform-configuration)
- [Created Resources](#created-resources)
- [TOC](#toc)
