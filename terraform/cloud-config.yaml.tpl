#cloud-config
groups:
  - docker
users:
  - name: jd
    groups: docker
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    ssh_import_id:
      - gh:25thhour
disable_root: true
packages:
  - docker.io
  - docker-compose
write_files:
  - encoding: b64
    content: ${COMPOSE}
    path: /run/compose/docker-compose.yaml
    defer: true
  - encoding: b64
    content: ${CADDYFILE}
    path: /run/compose/Caddyfile
    defer: true
  - encoding: b64
    content: ${CERT}
    path: /run/compose/cert.pem
    defer: true
  - encoding: b64
    content: ${KEY}
    path: /run/compose/key.pem
    defer: true
runcmd:
  - "cd /run/compose/"
  - "docker-compose up -d"
