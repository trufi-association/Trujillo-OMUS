import yaml
import requests

# Función para cargar la configuración desde el archivo YAML
def cargar_configuracion(ruta_archivo="config.yaml"):
    try:
        with open(ruta_archivo, "r") as archivo:
            return yaml.safe_load(archivo)
    except FileNotFoundError:
        print(f"No se encontró el archivo de configuración: {ruta_archivo}")
        exit(1)
    except yaml.YAMLError as e:
        print(f"Error al cargar el archivo YAML: {e}")
        exit(1)

# Cargar configuración
config = cargar_configuracion()

# Variables de Airtable
airtable_config = config["airtable"]
airtable_url = (
    f"https://api.airtable.com/v0/{airtable_config['base_id']}/"
    f"{airtable_config['table_name']}?view={airtable_config['view_name']}"
)
airtable_headers = {"Authorization": airtable_config["api_key"]}

# Variables de la API de Trufi
trufi_config = config["trufi_api"]
trufi_base_url = trufi_config["base_url"]
token = trufi_config["token"]
target_api_headers = {
    "accept": "*/*",
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

def eliminar_todas_las_categorias():
    """Elimina todas las categorías existentes en la API de Trufi."""
    print("Eliminando todas las categorías...")
    trufi_api_url = f"{trufi_base_url}/api/Categories"
    response = requests.get(trufi_api_url, headers=target_api_headers)

    if response.status_code == 200:
        data = response.json()
        for category in data:
            category_id = category["id"]
            delete_url = f"{trufi_base_url}/api/Categories/{category_id}"
            delete_response = requests.delete(delete_url, headers=target_api_headers)

            if delete_response.status_code in [200, 204]:
                print(f"Categoría con ID {category_id} eliminada exitosamente.")
            else:
                print(f"Error al eliminar la categoría con ID {category_id}: {delete_response.status_code}")
                print(delete_response.text)
    else:
        print(f"Error al obtener las categorías: {response.status_code}")
        print(response.text)

def crear_categorias():
    """Obtiene las categorías de Airtable y las crea en Trufi."""
    print("Creando nuevas categorías...")
    response = requests.get(airtable_url, headers=airtable_headers)

    if response.status_code == 200:
        data = response.json()
        for record in data['records']:
            fields = record['fields']

            # Preparar JSON para la nueva categoría
            organized_json = {
                "id": fields.get("ID", 0),
                "categoryName": fields.get("Categoryname", "default_name"),
                "hasVictim": fields.get("hasVictim", False),
                "hasDateTime": fields.get("hasDateTime", False)
            }

            parent_id = fields.get("parentid", 0)
            if parent_id != 0:
                organized_json["parentId"] = parent_id

            print("JSON generado:", organized_json)

            # Enviar la solicitud POST para crear la categoría
            post_response = requests.post(f"{trufi_base_url}/api/Categories/AddCategory", json=organized_json, headers=target_api_headers)

            if post_response.status_code in [201, 204]:
                print(f"Categoría '{organized_json['categoryName']}' creada exitosamente.")
            else:
                print(f"Error al crear la categoría '{organized_json['categoryName']}': {post_response.status_code}")
                print(post_response.text)
    else:
        print(f"Error al obtener los datos de Airtable: {response.status_code}")
        print(response.text)

def imprimir_arbol_categorias():
    """Imprime el árbol de categorías desde la API de Trufi."""
    print("\nÁrbol de categorías desde Trufi.dev:")
    trufi_api_url = f"{trufi_base_url}/api/Categories"
    response = requests.get(trufi_api_url, headers=target_api_headers)

    if response.status_code == 200:
        data = response.json()
        categories = {}
        root_categories = []

        for category in data:
            category_id = category["id"]
            category_name = category["categoryName"]
            parent_id = category.get("parentId", None)

            categories[category_id] = {
                "name": category_name,
                "parentId": parent_id,
                "children": []
            }

        for category_id, category_data in categories.items():
            parent_id = category_data["parentId"]
            if parent_id is None:
                root_categories.append(category_data)
            elif parent_id in categories:
                categories[parent_id]["children"].append(category_data)

        def print_tree(categories, level=0):
            """Función recursiva para imprimir las categorías en forma de árbol."""
            for category in categories:
                print("  " * level + f"- {category['name']}")
                if category["children"]:
                    print_tree(category["children"], level + 1)

        print_tree(root_categories)
    else:
        print(f"Error al obtener las categorías: {response.status_code}")
        print(response.text)

def sincronizar_text_it():
    """Ejecuta la sincronización con TextIt mediante una solicitud GET."""
    sync_url = f"{trufi_base_url}/api/Categories/SyncTextIt"
    print("\nSincronizando con TextIt...")
    response = requests.get(sync_url, headers=target_api_headers)

    if response.status_code == 200:
        print("Sincronización con TextIt exitosa.")
    else:
        print(f"Error en la sincronización con TextIt: {response.status_code}")
        print(response.text)

# Ejecutar las funciones en orden
eliminar_todas_las_categorias()
crear_categorias()
imprimir_arbol_categorias()
sincronizar_text_it()
