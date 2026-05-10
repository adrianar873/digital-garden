#!/bin/bash

# Script de instalación de Portainer 

set -e  # Detener el script si hay algún error

echo "=========================================="
echo "  Instalación de Portainer"
echo "=========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar si Docker está instalado
echo -e "${YELLOW}[1/4] Verificando Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo "Docker no está instalado. Por favor, instala Docker primero."
    exit 1
fi
echo -e "${GREEN}✓ Docker está instalado${NC}"
echo ""

# Crear volumen para Portainer
echo -e "${YELLOW}[2/4] Creando volumen de datos para Portainer...${NC}"
docker volume create portainer_data
echo -e "${GREEN}✓ Volumen creado exitosamente${NC}"
echo ""

# Ejecutar contenedor de Portainer
echo -e "${YELLOW}[3/4] Descargando e iniciando Portainer...${NC}"
docker run -d -p 8000:8000 -p 9443:9443 \
  --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

echo -e "${GREEN}✓ Portainer iniciado correctamente${NC}"
echo ""

# Obtener la IP del sistema
echo -e "${YELLOW}[4/4] Obteniendo información de acceso...${NC}"
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "=========================================="
echo -e "${GREEN}  ¡Instalación completada!${NC}"
echo "=========================================="
echo ""
echo "Accede a Portainer en tu navegador:"
echo -e "${GREEN}https://${IP}:9443${NC}"
echo ""
echo "Nota: La primera vez deberás crear un usuario administrador."
echo "Tienes 5 minutos desde el inicio para hacerlo."
echo ""
echo "Para verificar el estado del contenedor:"
echo "  docker ps | grep portainer"
echo ""
echo "Para ver los logs:"
echo "  docker logs portainer"
echo ""