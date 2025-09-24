#!/bin/bash
echo "=== 🧹 Limpiando laboratorio FHIR Secure ==="

# Parar y eliminar contenedores, redes y volúmenes
docker-compose down -v --remove-orphans

# Eliminar imágenes usadas en el laboratorio (opcional)
echo "¿Quieres eliminar también las imágenes de Docker usadas en el laboratorio? (s/n)"
read RESP
if [[ "$RESP" == "s" || "$RESP" == "S" ]]; then
  docker rmi postgres:15 hapiproject/hapi:v6.10.0 quay.io/keycloak/keycloak:24.0 envoyproxy/envoy:v1.30-latest || true
fi

echo "✅ Laboratorio limpio. Puedes volver a levantarlo con ./lab-up.sh"
