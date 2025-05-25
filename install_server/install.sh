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
  echo "  --generate-indexes, -g  Genera índices APT (.deb) y YUM (.rpm)"
  echo "  --firewall, -f         Configura UFW para permitir SSH, HTTP y HTTPS"
  echo "  --help, -h       Muestra esta ayuda"
  echo ""
  echo "Ejemplos:"
  echo "  $0 --init        Inicializa el servidor (instala nginx, estructura, config HTTP)"
  echo "  $0 --ssl         Activa HTTPS en NGINX si Certbot ya generó los certificados"
  echo "  $0 --generate-indexes  Genera los índices para repositorios APT y YUM"
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

generate_indexes() {
  echo "📦 Generando índice APT (.deb)..."
  DEB_DIR="/srv/repo/debian/dists/stable/main/binary-amd64"
  if [ -d "$DEB_DIR" ]; then
    cd "$DEB_DIR"
    dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
    echo "✅ Packages.gz generado en $DEB_DIR"
  else
    echo "⚠️  Directorio APT no encontrado: $DEB_DIR"
  fi

  echo "📦 Generando índice YUM (.rpm)..."
  RPM_DIR="/srv/repo/redhat"
  if [ -d "$RPM_DIR" ]; then
    createrepo "$RPM_DIR"
    echo "✅ repodata generado en $RPM_DIR"
  else
    echo "⚠️  Directorio RPM no encontrado: $RPM_DIR"
  fi
}

configure_firewall() {
  echo "🛡️ Configurando firewall con UFW..."
  sudo apt install -y ufw
  sudo ufw allow OpenSSH
  sudo ufw allow 80
  sudo ufw allow 443
  sudo ufw --force enable
  echo "✅ Firewall activo y configurado (SSH, HTTP, HTTPS)."
}

case "$1" in
  --init|-i)
    init_server
    ;;
  --ssl|-s)
    enable_ssl
    ;;
  --generate-indexes|-g)
    generate_indexes
    ;;
  --firewall|-f)
    configure_firewall
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