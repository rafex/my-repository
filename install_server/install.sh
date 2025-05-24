#!/bin/sh
set -e

CERT_DIR="/etc/letsencrypt/live/repository.rafex.app"
NGINX_CONF="/etc/nginx/sites-available/repo"

print_help() {
  echo "Uso: $0 [opciones]"
  echo ""
  echo "Opciones:"
  echo "  --init, -i       Instala dependencias y configura NGINX sin SSL"
  echo "  --ssl, -s        Ejecuta Certbot y activa HTTPS si ya existe el certificado"
  echo "  --help, -h       Muestra esta ayuda"
  echo ""
  echo "Ejemplos:"
  echo "  $0 --init        Inicializa el servidor (instala nginx, estructura, config HTTP)"
  echo "  $0 --ssl         Activa HTTPS en NGINX si Certbot ya generó los certificados"
}

init_server() {
  echo "🚀 Instalando dependencias para servidor de paquetes..."
  sudo apt update
  sudo apt install -y nginx dpkg-dev createrepo-c gnupg certbot python3-certbot-nginx

  echo "📁 Creando estructura de directorios..."
  sudo mkdir -p /srv/repo/{debian/dists/stable/main/binary-amd64,redhat}
  sudo chown -R "$USER:www-data" /srv/repo

  echo "📝 Configurando NGINX (HTTP temporal)..."
  sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name repository.rafex.app;

    root /srv/repo;
    index index.html;

    autoindex on;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

  sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/repo
  sudo rm -f /etc/nginx/sites-enabled/default
  sudo systemctl restart nginx

  echo "✅ Repositorio accesible temporalmente en HTTP: http://repository.rafex.app/"
}

enable_ssl() {
  if [ ! -d "$CERT_DIR" ]; then
    echo "🔐 Ejecutando Certbot para obtener certificado SSL..."
    sudo certbot --nginx --non-interactive --agree-tos --redirect -m rafex@rafex.dev -d repository.rafex.app
  else
    echo "✅ Certificado SSL ya existe. Reconfigurando NGINX..."

    sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name repository.rafex.app;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name repository.rafex.app;

    ssl_certificate $CERT_DIR/fullchain.pem;
    ssl_certificate_key $CERT_DIR/privkey.pem;

    root /srv/repo;
    index index.html;
    autoindex on;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

    sudo systemctl reload nginx
    echo "🔒 HTTPS activado correctamente en puerto 443."
  fi
}

case "$1" in
  --init|-i)
    init_server
    ;;
  --ssl|-s)
    enable_ssl
    ;;
  --help|-h|"")
    print_help
    ;;
  *)
    echo "❌ Opción desconocida: $1"
    print_help
    exit 1
    ;;
esac