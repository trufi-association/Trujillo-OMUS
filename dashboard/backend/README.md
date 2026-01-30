# OMUS Dashboard - Backend API

ASP.NET Core 8 REST API for the OMUS (Observatorio de Movilidad Urbana y Seguridad) Dashboard.

## Requirements

- .NET 8 SDK
- Docker and Docker Compose
- MySQL 8.0 (or use Docker)

## Quick Start

### Local Development

Para desarrollo local con puertos expuestos directamente:

```bash
# 1. Copiar el archivo de variables de entorno
cp .env.example .env

# 2. Editar .env con valores de desarrollo (localhost URLs)

# 3. Levantar con configuración de desarrollo
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

Esto expone:
- API: `http://localhost:8080`
- MySQL: `localhost:3306`

### Production (con trufi-server proxy)

Para producción usando el proxy trufi-server:

```bash
# 1. Copiar el archivo de variables de entorno
cp .env.example .env

# 2. Editar .env con valores de producción:
#    - API_URL: https://mrfisantre.trufi.app
#    - CORS_ORIGINS: (vacío, solo API_URL)
#    - Credenciales seguras (contraseñas, API keys)

# 3. Levantar (usa docker-compose.yml por defecto = producción)
docker compose up -d
```

**Configuración de producción:**
- Los puertos NO se exponen (manejado por trufi-server proxy)
- Se conecta a la red externa `trufi-server`
- Debe existir previamente el proxy trufi-server (https://github.com/trufi-association/trufi-server)
- El acceso se hace a través del proxy con HTTPS
- `ASPNETCORE_ENVIRONMENT=Production`

## Configuración de trufi-server

Este proyecto usa [trufi-server](https://github.com/trufi-association/trufi-server) como reverse proxy con SSL automático.

### Archivos de integración

- `trufi-proxy.json` - Autodescubrimiento del servicio
- `../trufi-server-config.json` - Configuración YARP para path-based routing

### Pasos de configuración

1. **Asegúrate que trufi-server esté corriendo:**
   ```bash
   cd /path/to/trufi-server
   docker compose up -d
   ```

2. **Verifica que la red `trufi-server` exista:**
   ```bash
   docker network ls | grep trufi-server
   ```

3. **Configura las rutas en trufi-server** agregando esto a `data/config/appsettings.json`:
   ```json
   {
     "ReverseProxy": {
       "Routes": {
         "omus-api-route": {
           "ClusterId": "omus-api",
           "Match": {
             "Hosts": ["omus.tmt.gob.pe"],
             "Path": "/api/{**catch-all}"
           }
         }
       },
       "Clusters": {
         "omus-api": {
           "Destinations": {
             "primary": {
               "Address": "http://omus-api:8080"
             }
           }
         }
       }
     }
   }
   ```

4. **Reinicia trufi-server** para aplicar la configuración:
   ```bash
   docker compose restart
   ```

5. **Despliega el backend:**
   ```bash
   docker compose up -d
   ```

### Verificar integración

```bash
# Ver todos los contenedores en la red trufi-server
docker network inspect trufi-server --format='{{range .Containers}}{{.Name}} {{end}}'

# Verificar logs del API
docker logs omus-api

# Probar endpoint
curl https://omus.tmt.gob.pe/api/Categories
```

### Without Docker

1. Install MySQL 8.0 locally
2. Create database `omus`
3. Copy `.env.example` to `.env` and configure
4. Run:

```bash
dotnet restore
dotnet run
```

## Configuration

All configuration is done via environment variables (`.env` file).

**Docker Compose files:**
- `docker-compose.yml` - Production configuration (default)
  - No exposes ports (uses trufi-server network)
  - `ASPNETCORE_ENVIRONMENT=Production`
- `docker-compose.dev.yml` - Development override
  - Exposes ports 8080 and 3306
  - Uses local docker network
  - `ASPNETCORE_ENVIRONMENT=Development`

**Environment variables** (`.env.example` template):
- `MYSQL_ROOT_PASSWORD` - Database password
- `JWT_KEY` - Secret key for JWT tokens (min 32 chars)
- `API_URL` - Base URL for API (auto-configures JWT issuer/audience and CORS)
  - Dev: `http://localhost:8080`
  - Prod: `https://mrfisantre.trufi.app`
- `API_KEY` - API key for report submissions
- `ADMIN_USERNAME` / `ADMIN_PASSWORD` - Admin credentials (password auto-hashed on startup)
- `CORS_ORIGINS` - Allowed CORS origins (comma-separated)
  - Dev: Leave empty (use `CORS_ALLOW_LOCALHOST` instead)
  - Prod: `https://omus.tmt.gob.pe`
- `CORS_ALLOW_LOCALHOST` - Allow any localhost port (for development)
  - Dev: `true`
  - Prod: `false`

### Generating Password Hash

In development mode, use the `/api/Auth/generate-hash` endpoint:

```bash
curl -X POST http://localhost:8080/api/Auth/generate-hash \
  -H "Content-Type: application/json" \
  -d '{"password": "your-password"}'
```

## API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/Auth/login` | - | Get JWT token |
| GET | `/api/Categories` | - | List categories |
| POST | `/api/Categories/AddCategory` | JWT | Add category |
| GET | `/api/Categories/SyncTextIt` | JWT | Sync to TextIt |
| GET | `/api/Reports` | JWT | List reports |
| POST | `/api/Reports` | API Key | Create report |
| GET | `/api/VialActors` | - | List vial actors |

Full API documentation available at `/api/swagger` when running.

## Security Features

- JWT authentication with 24-hour expiration
- BCrypt password hashing
- Rate limiting (5 login attempts/min, 100 reports/min)
- CORS policy with configurable origins
- SSRF protection on proxy endpoint
- API Key moved from query string to header

## Project Structure

```
backend/
├── controllers/     # API Controllers
├── data/           # DbContext and initializers
├── middleware/     # Custom middleware (error handling)
├── models/         # Entity models
├── services/       # Business logic services
├── Migrations/     # EF Core migrations
├── scripts/        # Deployment scripts
└── Program.cs      # Application entry point
```

## Nginx Configuration (Production)

```nginx
location /api {
    proxy_pass http://api:8080/api;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection keep-alive;
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
    proxy_set_header X-Real-IP $remote_addr;
}
```

## Troubleshooting

### JWT Key Error
If you see "JWT Key must be configured", ensure `JWT_KEY` is set and is at least 32 characters.

### Database Connection
Ensure MySQL is running and the connection string is correct. Check with:
```bash
docker compose logs db
```

### Admin Login Fails
Verify `ADMIN_USERNAME` and `ADMIN_PASSWORD_HASH` are set correctly. Use the generate-hash endpoint to create a new hash.
