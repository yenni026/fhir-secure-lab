# 🔐 FHIR Secure Lab con Keycloak + Envoy

Este laboratorio despliega un entorno completo con:

- **HAPI FHIR** como servidor FHIR
- **Keycloak** como Identity Provider (OAuth2 / OpenID Connect)
- **Envoy** como API Gateway que valida tokens JWT
- **Postgres** como base de datos para HAPI FHIR

La seguridad se logra haciendo que **Envoy** acepte solo peticiones con tokens válidos emitidos por **Keycloak**.

---

## 📦 Requisitos previos

- [Docker](https://docs.docker.com/get-docker/)  
- [Docker Compose](https://docs.docker.com/compose/install/)  
- [Postman](https://www.postman.com/downloads/) (para probar manualmente)

---

## 🚀 Despliegue del laboratorio

1. **Clonar el repositorio:**

   ```bash
   git clone https://github.com/tu-repo/fhir-secure-lab.git
   cd fhir-secure-lab

2. **Levantar el laboratorio con los scripts incluidos:**
    ```bash
    ./scripts/lab-up.sh

Esto iniciará:
- postgres (base de datos para HAPI FHIR)
- hapi-fhir (servidor FHIR en http://localhost:8080/fhir)
- keycloak (gestor de identidad en http://localhost:8081)
- envoy (proxy seguro en http://localhost:9090/fhir)

3. **Verifica que todo está corriendo:**
     ```bash
    docker ps
---

## 🔑 Configuración de Keycloak
La configuración está automatizada en los scripts.
- Al levantar el laboratorio, se crea automáticamente:
    - - Realm: fhir-realm.
    Client: fhir-client.
    Client Secret: my-client-secret.
    Grant Type permitido: client_credentials.
    Roles y permisos mínimos para acceder a la API.

- Puedes comprobarlo entrando a:
- 👉 http://localhost:8081 (usuario: admin, contraseña: admin si configuraste así).
---

**🧪 Pruebas automáticas con script**
     ```bash
    ./scripts/lab-test.sh

- Este hace lo siguiente:

1. Solicita un token a Keycloak (client_credentials).
2. Prueba un POST /Patient sin token → debe dar 401 Unauthorized.
3. Prueba un POST /Patient con token válido → debe dar 201 Created.
---

## 🧪 Pruebas manuales con Postman
1. **Probar acceso sin token**
     ```bash
    Método: POST
    URL: http://localhost:9090/fhir/Patient
    Headers:
    
    Content-Type: application/fhir+json

    Body (JSON):
    ``json
    {
        "resourceType": "Patient",
        "name": [
          {
            "use": "official",
            "family": "Perez",
            "given": ["Maria"]
          }
        ]
    }
- 👉 Respuesta esperada:
- 401 Unauthorized con mensaje Jwt is missing 

2. **Obtener un token en Postman**
     ```bash
    -En Postman, abre la pestaña Authorization.
    -Selecciona OAuth 2.0.
    -Haz clic en Get New Access Token.
    -Completa los campos:
        Token Name: fhir-client
        Grant Type: Client Credentials
        Access Token URL:
            http://localhost:8081/realms/fhir-realm/protocol/openid-connect/token
        Client ID: fhir-client
        Client Secret: my-client-secret
        Scope: (vacío)
        Client Authentication: Send as Basic Auth header
    -Haz clic en Request Token.
    -Finalmente, selecciona Use Token.
    
3. **Probar acceso con token**
     ```bash
    Método: POST
    URL: http://localhost:9090/fhir/Patient
    Headers:
        Content-Type: application/fhir+json
        Authorization: Bearer <TOKEN>
    Body (JSON):
        {
            "resourceType": "Patient",
            "name": [
                {
                "use": "official",
                "family": "Lopez",
                "given": ["Ana"]
                }
            ]
        }
- 👉 Respuesta esperada:
- 201 Created con un recurso Patient.

🛑 Parar y limpiar el laboratorio

    Cuando termines, puedes apagar todo con:
    ./scripts/lab-down.sh
    Esto detendrá y eliminará los contenedores y la red del laboratorio.

📌 Endpoints principales

    HAPI FHIR directo (sin seguridad):
        http://localhost:8080/fhir
    HAPI FHIR seguro (via Envoy + JWT):
        http://localhost:9090/fhir
    Keycloak (admin UI):
        http://localhost:8081


