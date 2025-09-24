#!/bin/bash
set -e

echo "=== 🚀 Instalación del laboratorio FHIR Secure (Docker + Keycloak + HAPI) ==="

# -------------------------------
# 1. Instalar Docker y dependencias
# -------------------------------
echo "[1/3] Instalando Docker y dependencias..."

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

# Agregar clave GPG oficial de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg

# Repositorio Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# -------------------------------
# 2. Instalar Docker Compose (si no está)
# -------------------------------
if ! command -v docker-compose &> /dev/null
then
  echo "[2/3] Instalando Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/download/2.24.7/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
else
  echo "[2/3] Docker Compose ya está instalado."
fi

# -------------------------------
# 3. Crear grupo docker y dar permisos
# -------------------------------
echo "[3/3] Configurando permisos de Docker..."

sudo groupadd docker || true
sudo usermod -aG docker $USER

echo "⚠️ Debes cerrar sesión y volver a entrar para que los permisos surtan efecto."