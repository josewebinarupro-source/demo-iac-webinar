#!/bin/bash
# Script arranque demo IaC - Webinar UPRO

# 1. Instalar Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt update && apt install -y terraform

# 2. Clonar repo
git clone https://github.com/josewebinarupro-source/demo-iac-webinar
cd demo-iac-webinar

# 3. Crear vars de entorno
echo 'base_path = "/root/demo-iac-webinar"' > killercoda.tfvars
