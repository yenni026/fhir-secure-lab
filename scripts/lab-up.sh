#!/bin/bash
# Levanta todo el laboratorio FHIR + Keycloak + Envoy

echo "🚀 Levantando laboratorio FHIR Secure..."

docker compose up -d

echo "⌛ Esperando que los contenedores arranquen..."
sleep 20

echo "✅ Todo arriba. Keycloak en http://localhost:8081"
echo "✅ HAPI FHIR en http://localhost:8080/fhir"
echo "✅ Envoy en http://localhost:9090 (usa este endpoint con token)"
