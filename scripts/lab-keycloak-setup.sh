#!/bin/bash
set -e

# ==============================
# Variables
# ==============================
KEYCLOAK_URL="http://localhost:8081"
REALM="fhir-realm"
CLIENT_ID="fhir-client"
CLIENT_SECRET="my-fhir-secret"
USER_NAME="medico"
USER_PASS="medico123"
ADMIN_USER="admin"
ADMIN_PASS="admin"

echo "⏳ Esperando que Keycloak arranque..."
sleep 20  # Ajustar si tu PC es lenta

# ==============================
# 1. Obtener token de admin
# ==============================
ACCESS_TOKEN=$(curl -s \
  -d "client_id=admin-cli" \
  -d "username=$ADMIN_USER" \
  -d "password=$ADMIN_PASS" \
  -d "grant_type=password" \
  "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
  | jq -r '.access_token')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
  echo "❌ No se pudo autenticar con Keycloak. Verifica admin/admin."
  exit 1
fi

echo "✅ Autenticado como admin"

# ==============================
# 2. Crear Realm
# ==============================
echo "➡️ Creando realm: $REALM"
curl -s -X POST "$KEYCLOAK_URL/admin/realms" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
        \"realm\": \"$REALM\",
        \"enabled\": true
      }" || true

# ==============================
# 3. Crear Client
# ==============================
echo "➡️ Creando client: $CLIENT_ID"
curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM/clients" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
        \"clientId\": \"$CLIENT_ID\",
        \"enabled\": true,
        \"protocol\": \"openid-connect\",
        \"publicClient\": false,
        \"secret\": \"$CLIENT_SECRET\",
        \"directAccessGrantsEnabled\": true
      }" || true

# ==============================
# 4. Crear User
# ==============================
echo "➡️ Creando user: $USER_NAME"
curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM/users" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
        \"username\": \"$USER_NAME\",
        \"enabled\": true,
        \"credentials\": [{
          \"type\": \"password\",
          \"value\": \"$USER_PASS\",
          \"temporary\": false
        }]
      }" || true

echo "✅ Keycloak configurado: Realm=$REALM, Client=$CLIENT_ID, User=$USER_NAME/$USER_PASS"
