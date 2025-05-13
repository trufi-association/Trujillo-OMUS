# Trujillo-OMUS

**OMUS** (Observatorio de Movilidad Urbana Sostenible) es una plataforma web desarrollada como medida piloto para la ciudad de **Trujillo, Perú**. Este repositorio contiene el código fuente y scripts asociados al sistema de recopilación, visualización y análisis de datos de movilidad urbana, con enfoque en el transporte público.

Plataforma en línea: [https://omus.tmt.gob.pe](https://omus.tmt.gob.pe)

## Estructura del Repositorio

- **`GTFS-Peru-Trujillo/`**  
  Scripts para la generación del archivo GTFS (General Transit Feed Specification) a partir de datos de OpenStreetMap.  
  Es la base para representar rutas en el visor geográfico de OMUS.

- **`dashboard/`**  
  Aplicación web desarrollada con **Flutter** (frontend) y **.NET** (backend). Contiene el visor de mapas, tableros estadísticos (Power BI embebido) y panel de administración.

- **`poblador_categorias/`**  
  Script y backup de la estructura del flujo del chatbot implementado con **TextIt** (RapidPro). Se encarga de poblar y sincronizar las categorías utilizadas para clasificar los reportes ciudadanos.

## Tecnologías Utilizadas

- Frontend: [Flutter](https://flutter.dev/)
- Backend: [.NET](https://dotnet.microsoft.com/)
- Visualización de datos: [Power BI](https://powerbi.microsoft.com/)
- Datos de transporte: [GTFS](https://gtfs.org/), [OpenStreetMap](https://www.openstreetmap.org/)
- Chatbot: [TextIt](https://texti)
