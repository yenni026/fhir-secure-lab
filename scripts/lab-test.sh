#!/bin/bash
# Script para probar acceso con y sin token usando Client Credentials

KC=http://localhost:8081/realms/fhir-realm/protocol/openid-connect/token
CLIENT_ID=fhir-client
CLIENT_SECRET=my-fhir-secret

echo "🔑 Obteniendo token de Keycloak (Client Credentials)..."
ACCESS_TOKEN=$(curl -s -X POST $KC \
  -d "grant_type=client_credentials" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  | jq -r '.access_token')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ No se pudo obtener token. Revisa client_id o client_secret."
  exit 1
fi

echo "✅ Token obtenido:"
echo $ACCESS_TOKEN
echo



echo "🚫 Probando acceso SIN token..."
curl -i -X POST http://localhost:9090/fhir/Patient \
  -H "Content-Type: application/fhir+json" \
  -d '{
    "resourceType": "Patient",
    "name": [
      {
        "use": "official",
        "family": "Prueba",
        "given": ["SinToken"]
      }
    ]
  }'




echo "✅ Probando POST /Patient con token..."
curl -i -X POST http://localhost:9090/fhir/Patient \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/fhir+json" \
  -d '{"resourceType":"Patient","name":[{"use":"official","family":"Reyes","given":["Jaider"]}]}'
echo
