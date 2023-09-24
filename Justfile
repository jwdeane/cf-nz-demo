alias init := bootstrap
alias cleanup := remove-env

zone := "cflr.one"

@_default:
    just --list

# format the Justfile
@fmt:
    just --fmt --unstable

# creates .env
@bootstrap: load-env

# set env vars from 1Password
@load-env:
    echo "💉 Injecting secrets into .env"
    op inject -i .env.example -o .env > /dev/null
    echo "✨ .env written successfully"
    echo "💡 Done. Remember to source .env"

# set vars for GitHub Actions
@set-github-vars:
    echo "🔐 writing secrets to GitHub"
    gh secret set -f .env

# remove local .env ONLY
remove-env:
    echo "Removing .env file"
    rm .env

# display email DNS records
show-dns domain:
    dog TXT {{ domain }} _dmarc.{{ domain }} '*._domainkey.{{ domain }}'

# display zone settings
show-zone zone_id:
    http "https://api.cloudflare.com/client/v4/zones/{{ zone_id }}/settings" "x-auth-email:$CLOUDFLARE_EMAIL" "x-auth-key:$CLOUDFLARE_API_KEY" | jq -c '.result[] | { id, value }'

#-----------------------------------------------------------
# Terraform
#-----------------------------------------------------------

tf-init *args:
    terraform -chdir=terraform init {{ args }}

tf-plan:
    terraform -chdir=terraform plan

tf-apply *args:
    terraform -chdir=terraform apply {{ args }}

# output a single resource
tf-output resource:
    terraform -chdir=terraform output -json {{ resource }}

# outputs all resources
tf-outputs:
    terraform -chdir=terraform output -json

# 🔥 danger
tf-destroy:
    terraform -chdir=terraform destroy

#-----------------------------------------------------------
# 1-certificates
#-----------------------------------------------------------

# get droplet IPv4 address
ip name="1-certificates":
    doctl compute droplet get {{ name }} -o json | jq -r '.[].networks.v4[0].ip_address'

add-cfip-firewall name="1-certificates":
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Setting Digital Ocean variables."
    SSH_FIREWALL_ID=$(doctl compute firewall list -o json | jq -r '.[] | select(.name == "ssh-all").id')
    CLOUDFLARE_FIREWALL_ID=$(doctl compute firewall list -o json | jq -r '.[] | select(.name == "cloudflare-ips").id')
    DROPLET_ID=$(doctl compute droplet get {{ name }} -o json | jq -r '.[].id')

    echo "Adding droplets to firewall(s)."
    doctl compute firewall add-droplets $SSH_FIREWALL_ID --droplet-ids $DROPLET_ID
    doctl compute firewall add-droplets $CLOUDFLARE_FIREWALL_ID --droplet-ids $DROPLET_ID

remove-firewalls name="1-certificates":
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Setting Digital Ocean variables."
    SSH_FIREWALL_ID=$(doctl compute firewall list -o json | jq -r '.[] | select(.name == "ssh-all").id')
    CLOUDFLARE_FIREWALL_ID=$(doctl compute firewall list -o json | jq -r '.[] | select(.name == "cloudflare-ips").id')
    DROPLET_ID=$(doctl compute droplet get {{ name }} -o json | jq -r '.[].id')

    echo "Removing droplets from firewall(s)."
    doctl compute firewall remove-droplets $SSH_FIREWALL_ID --droplet-ids $DROPLET_ID
    doctl compute firewall remove-droplets $CLOUDFLARE_FIREWALL_ID --droplet-ids $DROPLET_ID

# ssh into droplet
ssh name="1-certificates":
    ssh $(doctl compute droplet get {{ name }} -o json | jq -r '.[].networks.v4[0].ip_address')

@sslscan name="1-certificates":
    # remove the firewall temporarily
    just remove-firewalls

    echo "Run sslscan against the droplets public IP."
    echo "A Cloudflare Origin Certificate will be presented."
    echo "NOTE: this will fail if the cfip firewall is in place.\n"
    sslscan --sni-name=httpbin.{{ zone }} $(doctl compute droplet get {{ name }} -o json | jq -r '.[].networks.v4[0].ip_address')

    # re-add the firewall
    just add-cfip-firewall

@sslscan-direct name="1-certificates":
    # remove the firewall temporarily
    just remove-firewalls

    echo "Run sslscan against the droplets public IP, unproxied, bypassing Cloudflare."
    echo "Once connected, a non-Cloudflare certificate (managed by Caddy) will be presented."
    echo "NOTE: this will fail if the cfip firewall is in place.\n"
    sslscan --sni-name=httpbin-direct.{{ zone }} $(doctl compute droplet get {{ name }} -o json | jq -r '.[].networks.v4[0].ip_address')

    # re-add the firewall
    just add-cfip-firewall

sslscan-tunnel:
    sslscan httpbin-tunnel.{{ zone }}

#-----------------------------------------------------------
# 2-tunnel
# -----------------------------------------------------------

lockdown-ingress name="2-tunnel":
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Setting Digital Ocean variables."
    SSH_FIREWALL_ID=$(doctl compute firewall list -o json | jq -r '.[] | select(.name == "ssh-all").id')
    DROPLET_ID=$(doctl compute droplet get {{ name }} -o json | jq -r '.[].id')

    echo "Adding droplets to firewall(s)."
    doctl compute firewall add-droplets $SSH_FIREWALL_ID --droplet-ids $DROPLET_ID

#-----------------------------------------------------------
# 5-zt
#-----------------------------------------------------------

test-dns-block name="malware.testcategory.com":
    dog {{ name }}

test-dlp:
    https https://httpbin.cflr.one/post secret=badger
