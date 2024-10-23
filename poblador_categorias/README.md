# Poblador de Categorías

Este proyecto sincroniza categorías de Airtable con una API en Trufi. Elimina categorías existentes en Trufi y crea nuevas según los datos en Airtable.

## **Requisitos**

Asegúrate de tener Python instalado. Instala las dependencias con:

```bash
pip install requests pyyaml

/tu_proyecto
│
├── poblador.py           # Script principal
├── config.yaml.example   # Ejemplo de configuración
├── config.yaml           # Archivo de configuración (IGNORADO en GitHub)
└── README.md             # Instrucciones


cp config.yaml.example config.yaml
airtable:
  api_key: "TU_API_KEY_AIRTABLE"
  base_id: "TU_BASE_ID"
  table_name: "Arbol_categorias"
  view_name: "Basico"

trufi_api:
  base_url: "https://omus-dev.trufi.dev"
  token: "TU_TOKEN_TRUFI"

python3 poblador.py
