#!/bin/bash

# Script de instalación de Immich


set -e  # Detener el script si hay algún error

echo "=========================================="
echo "  Instalación de Immich"
echo "=========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar si Docker está instalado
echo -e "${YELLOW}[1/7] Verificando Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker no está instalado. Por favor, instala Docker primero.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker está instalado${NC}"
echo ""

# Verificar si Docker Compose está instalado
echo -e "${YELLOW}[2/7] Verificando Docker Compose...${NC}"
if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}Docker Compose no está instalado. Por favor, instálalo primero.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose está instalado${NC}"
echo ""

# Crear directorio para Immich
echo -e "${YELLOW}[3/7] Creando directorio de instalación...${NC}"
IMMICH_DIR="$HOME/immich"
mkdir -p "$IMMICH_DIR"
cd "$IMMICH_DIR"
echo -e "${GREEN}✓ Directorio creado: $IMMICH_DIR${NC}"
echo ""

# Descargar docker-compose.yml
echo -e "${YELLOW}[4/7] Descargando docker-compose.yml...${NC}"
wget -O docker-compose.yml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
echo -e "${GREEN}✓ docker-compose.yml descargado${NC}"
echo ""

# Descargar archivo .env de ejemplo
echo -e "${YELLOW}[5/7] Descargando archivo de configuración .env...${NC}"
wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env
echo -e "${GREEN}✓ Archivo .env descargado${NC}"
echo ""

# Crear directorio para las fotos
echo -e "${YELLOW}[6/7] Configurando directorio de almacenamiento...${NC}"
UPLOAD_DIR="$HOME/immich/library"
mkdir -p "$UPLOAD_DIR"

# Actualizar la ruta en el archivo .env
sed -i "s|UPLOAD_LOCATION=.*|UPLOAD_LOCATION=$UPLOAD_DIR|g" .env

echo -e "${GREEN}✓ Directorio de almacenamiento configurado: $UPLOAD_DIR${NC}"
echo ""
echo -e "${YELLOW}IMPORTANTE: Edita el archivo .env para cambiar la contraseña de la base de datos${NC}"
echo "Puedes hacerlo con: nano $IMMICH_DIR/.env"
echo "Busca la línea DB_PASSWORD y cámbiala por una contraseña segura"
echo ""
read -p "¿Deseas editar el archivo .env ahora? (s/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Ss]$ ]]; then
    nano .env
fi

# Iniciar los contenedores
echo ""
echo -e "${YELLOW}[7/7] Iniciando contenedores de Immich...${NC}"
docker compose up -d

echo ""
echo "Esperando a que los servicios se inicien..."
sleep 10

# Verificar el estado
docker compose ps

echo ""
echo "=========================================="
echo -e "${GREEN}  ¡Instalación completada!${NC}"
echo "=========================================="
echo ""

# Obtener la IP del sistema
IP=$(hostname -I | awk '{print $1}')

echo "Accede a Immich en tu navegador:"
echo -e "${GREEN}http://${IP}:2283${NC}"
echo ""
echo "Archivos de configuración en: $IMMICH_DIR"
echo "Fotos y vídeos se guardarán en: $UPLOAD_DIR"
echo ""
echo "Comandos útiles:"
echo "  Ver logs:              cd $IMMICH_DIR && docker compose logs -f"
echo "  Detener servicios:     cd $IMMICH_DIR && docker compose down"
echo "  Reiniciar servicios:   cd $IMMICH_DIR && docker compose restart"
echo "  Actualizar Immich:     cd $IMMICH_DIR && docker compose pull && docker compose up -d"
echo ""