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
runcmd:
  - "cd /run/compose/"
  - "docker-compose up -d"
