# OMUS Dashboard - Frontend

Flutter Web application for the OMUS (Observatorio de Movilidad Urbana y Seguridad) Dashboard.

## Requirements

- Flutter SDK 3.4.3+
- Dart SDK 3.4.3+
- Docker and Docker Compose (for production deployment)

## Quick Start

### Local Development

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Configurar la URL del API en lib/env.dart
# Descomentar la línea de localhost:
# const String apiUrl = "http://localhost:8080/api";

# 3. Ejecutar en modo desarrollo
flutter run -d chrome
```

### Build para Producción

```bash
# 1. Configurar la URL del API en lib/env.dart
# Usar la URL de producción:
const String apiUrl = "https://omus.tmt.gob.pe/api";

# 2. Compilar para web
flutter build web

# 3. Los archivos estáticos estarán en build/web/
```

### Deployment con Docker (trufi-server)

```bash
# 1. Compilar el frontend
flutter build web

# 2. Desplegar con Docker
docker compose up -d
```

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

2. **Configura las rutas en trufi-server** agregando esto a `data/config/appsettings.json`:
   ```json
   {
     "ReverseProxy": {
       "Routes": {
         "omus-dashboard-route": {
           "ClusterId": "omus-dashboard",
           "Match": {
             "Hosts": ["omus.tmt.gob.pe"],
             "Path": "/{**catch-all}"
           }
         }
       },
       "Clusters": {
         "omus-dashboard": {
           "Destinations": {
             "primary": {
               "Address": "http://omus-dashboard:80"
             }
           }
         }
       }
     }
   }
   ```

   **Importante:** La ruta del API (`/api/*`) debe tener mayor prioridad que la ruta del dashboard (`/*`). Asegúrate de que ambas rutas estén configuradas correctamente.

3. **Reinicia trufi-server:**
   ```bash
   docker compose restart
   ```

4. **Despliega el frontend:**
   ```bash
   docker compose up -d
   ```

### Verificar integración

```bash
# Ver contenedores en la red trufi-server
docker network inspect trufi-server --format='{{range .Containers}}{{.Name}} {{end}}'

# Verificar logs
docker logs omus-dashboard

# Probar acceso
curl https://omus.tmt.gob.pe/
```

## Configuración

### Variables de entorno (lib/env.dart)

```dart
// Producción
const String apiUrl = "https://omus.tmt.gob.pe/api";

// Desarrollo local
// const String apiUrl = "http://localhost:8080/api";
```

### Nginx (nginx/app.conf)

El servidor nginx está configurado para:
- Servir archivos estáticos de Flutter Web
- Manejar rutas SPA (Single Page Application)
- Endpoint de health check en `/health`

## Project Structure

```
omus/
├── lib/
│   ├── core/           # Router, tema, configuración
│   ├── features/       # Pantallas y widgets por feature
│   ├── services/       # API client, modelos, servicios
│   └── main.dart       # Entry point
├── assets/             # GTFS data, imágenes
├── nginx/              # Configuración nginx
├── build/web/          # Build output (gitignored)
├── docker-compose.yml  # Deployment config
└── trufi-proxy.json    # trufi-server integration
```

## Features

- Dashboard administrativo con autenticación JWT
- Visualización de reportes en mapa interactivo
- Estadísticas y gráficos de datos
- Gestión de categorías de incidentes
- Visor de rutas GTFS
