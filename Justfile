alias init := bootstrap
alias cleanup := remove-env

@_default:
    just --list

# format the Justfile
@fmt:
    just --fmt --unstable

# load env and init tf
@bootstrap: load-env tf-init

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
