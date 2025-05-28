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
  echo "  --markdown, -m        Instala 'markdown' y genera index.html desde README.md"
  echo "  --report, -r        Genera informe de acceso en tiempo real con contraseña"
  echo "  --reindex, -R       Regenera Packages.gz para amd64 y arm64 (NOTA: -r ahora es para el informe)"
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
  sudo mkdir -p /srv/repo/debian/dists/stable/main/binary-amd64
  sudo mkdir -p /srv/repo/debian/dists/stable/main/binary-arm64
  sudo mkdir -p /srv/repo/redhat
  sudo chown -R "$USER:www-data" /srv/repo

  sudo chmod -R 775 /srv/repo/debian/dists/stable/main/binary-amd64
  sudo chmod -R 775 /srv/repo/debian/dists/stable/main/binary-arm64

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

  echo "📄 Generando index.html a partir de README.md..."
  if command -v markdown >/dev/null 2>&1; then
    markdown /opt/src/my-repository/README.md > /srv/repo/index.html
  else
    echo "<pre>" > /srv/repo/index.html
    cat /opt/src/my-repository/README.md >> /srv/repo/index.html
    echo "</pre>" >> /srv/repo/index.html
  fi
  echo "✅ Archivo index.html generado en /srv/repo/"
  echo "✅ Repositorio accesible temporalmente en HTTP: http://repository.rafex.app/"
}

install_markdown_index() {
  echo "📥 Instalando 'markdown' si es necesario..."
  if ! command -v markdown >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y markdown
  fi

  echo "📄 Generando index.html a partir de README.md..."
  echo '<!DOCTYPE html>' > /srv/repo/index.html
  echo '<html lang="es"><head><meta charset="UTF-8"><title>Repositorio de Rafex</title></head><body>' >> /srv/repo/index.html
  markdown /opt/src/my-repository/README.md >> /srv/repo/index.html
  echo '</body></html>' >> /srv/repo/index.html
  echo "✅ Archivo index.html generado con 'markdown'."
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
  echo "🔄 Regenerando índices APT (.deb) para amd64 y arm64..."
  cd /srv/repo/debian

  for arch in amd64 arm64; do
    ARCH_DIR="dists/stable/main/binary-$arch"
    echo "📦 Generando Packages para $arch..."
    apt-ftparchive packages "$ARCH_DIR" > "$ARCH_DIR/Packages"
    gzip -9c "$ARCH_DIR/Packages" > "$ARCH_DIR/Packages.gz"
  done

  echo "🔏 Firmando Release e InRelease..."
  rm -f dists/stable/Release dists/stable/Release.gpg dists/stable/InRelease
  apt-ftparchive -c /opt/src/my-repository/install_server/config/release.conf release dists/stable > dists/stable/Release
  gpg --batch --yes --default-key rafex@rafex.dev -abs -o dists/stable/Release.gpg dists/stable/Release
  gpg --batch --yes --default-key rafex@rafex.dev --clearsign -o dists/stable/InRelease dists/stable/Release

  echo "📦 Generando índice YUM (.rpm)..."
  RPM_DIR="/srv/repo/redhat"
  if [ -d "$RPM_DIR" ]; then
    createrepo "$RPM_DIR"
    echo "✅ repodata generado en $RPM_DIR"
  else
    echo "⚠️  Directorio RPM no encontrado: $RPM_DIR"
  fi

  echo "✅ Reindexación y firma completadas."
}

configure_firewall() {
  echo "🛡️ Configurando firewall con UFW..."
<<<<<<< ADD_REPORT_FUNCTIONS

# --- Funciones para generación de informe con goaccess ---

# Configura autenticación básica para el informe
enable_report_auth() {
  REPORT_HTML="/srv/repo/report.html"
  HTPASSWD_FILE="/srv/repo/.htpasswd"

  echo "🔐 Configurando usuario y contraseña para el informe."
  read -p "Introduce el nombre de usuario para el informe: " REPORT_USER

  cat << 'USAGE'
Usage:
        htpasswd [-cimB25dpsDv] [-C cost] [-r rounds] passwordfile username
        htpasswd -b[cmB25dpsDv] [-C cost] [-r rounds] passwordfile username password

        htpasswd -n[imB25dps] [-C cost] [-r rounds] username
        htpasswd -nb[mB25dps] [-C cost] [-r rounds] username password
 -c  Create a new file.
 -n  Don't update file; display results on stdout.
 -b  Use the password from the command line rather than prompting for it.
 -i  Read password from stdin without verification (for script usage).
 -m  Force MD5 hashing of the password (default).
 -2  Force SHA-256 hashing of the password (secure).
 -5  Force SHA-512 hashing of the password (secure).
 -B  Force bcrypt hashing of the password (very secure).
 -C  Set the computing time used for the bcrypt algorithm
     (higher is more secure but slower, default: 5, valid: 4 to 17).
 -r  Set the number of rounds used for the SHA-256, SHA-512 algorithms
     (higher is more secure but slower, default: 5000).
 -d  Force CRYPT hashing of the password (8 chars max, insecure).
 -s  Force SHA-1 hashing of the password (insecure).
 -p  Do not hash the password (plaintext, insecure).
 -D  Delete the specified user.
 -v  Verify password for the specified user.
USAGE

  echo "Configurando archivo de contraseñas en $HTPASSWD_FILE"
  sudo htpasswd -c -i "$HTPASSWD_FILE" "$REPORT_USER"
  sudo chown "$USER:www-data" "$HTPASSWD_FILE"
  sudo chmod 640 "$HTPASSWD_FILE"
}

# Ejecuta goaccess en segundo plano y genera reporte HTML
run_report() {
  echo "🏃 Ejecutando goaccess en segundo plano. Presiona Ctrl+C para detener."
  sudo goaccess /var/log/nginx/access.log --log-format=COMBINED --real-time-html --addr=0.0.0.0 -o "$REPORT_HTML" &
  GOACCESS_PID=$!
  echo "Goaccess PID: $GOACCESS_PID"
}

# Limpieza de archivos al terminar
cleanup_report() {
  echo "🗑️ Eliminando archivo de informe ($REPORT_HTML) y archivo de contraseña ($HTPASSWD_FILE)..."
  sudo rm -f "$REPORT_HTML" "$HTPASSWD_FILE"
  echo "✅ Limpieza completa."
  exit 0
}
<<<<<<< END_ADD
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
  --markdown|-m)
    install_markdown_index
    ;;
  --report|-r)
    # Configuración y ejecución de informe de acceso en tiempo real
    enable_report_auth
    trap cleanup_report INT
    run_report
    wait $GOACCESS_PID
    ;;
  --reindex|-R)
    generate_indexes
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