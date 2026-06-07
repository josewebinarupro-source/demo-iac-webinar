#!/bin/bash

echo "🚀 Demo IaC — Webinar Transformación Digital"
echo "============================================="

# 1. Instalar Terraform si no está
if ! command -v terraform &> /dev/null; then
    echo "📦 Instalando Terraform..."
    wget -q https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_linux_amd64.zip
    unzip -q terraform_1.9.0_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    rm terraform_1.9.0_linux_amd64.zip
    echo "✅ Terraform instalado"
else
    echo "✅ Terraform ya instalado"
fi

# 2. Clonar el repo si no existe
if [ ! -d "demo-iac-webinar" ]; then
    echo "📥 Clonando repositorio..."
    git clone https://github.com/josewebinarupro-source/demo-iac-webinar
    echo "✅ Repositorio clonado"
fi

cd demo-iac-webinar

# 3. Detectar entorno automáticamente
if [ -d "/workspaces" ]; then
    ENV="codespaces"
    BASE_PATH="/workspaces/demo-iac-webinar"
    APP_PORT=5000
elif [ "$USER" = "root" ]; then
    ENV="killercoda"
    BASE_PATH="/root/demo-iac-webinar"
    APP_PORT=5001
else
    ENV="local"
    BASE_PATH="$HOME/demo-iac-webinar"
    APP_PORT=5000
fi

echo "✅ Entorno detectado: $ENV"
echo "✅ Ruta base: $BASE_PATH"
echo "✅ Puerto app: $APP_PORT"

# 4. Crear variables para el entorno
cat > ${ENV}.tfvars << EOF
base_path = "$BASE_PATH"
app_port  = $APP_PORT
EOF

echo "✅ Variables creadas"

# 5. Desplegar
terraform init -upgrade
terraform apply -var-file="${ENV}.tfvars" -auto-approve

echo ""
echo "🎉 ¡Todo desplegado!"
echo "========================="
echo "🌐 Web:       http://localhost:8080"
echo "📋 App:       http://localhost:$APP_PORT"
echo "🗄️  pgAdmin:  http://localhost:8081"
echo "🐳 Portainer: http://localhost:9000"
