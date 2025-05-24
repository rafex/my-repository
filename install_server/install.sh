# install.sh
#!/bin/sh
set -e

echo "🚀 Instalando dependencias para servidor de paquetes..."

# Actualizar e instalar paquetes necesarios
sudo apt update
sudo apt install -y nginx dpkg-dev createrepo-c gnupg

# Crear estructura de directorios
sudo mkdir -p /srv/repo/{debian/dists/stable/main/binary-amd64,redhat}
sudo chown -R "$USER:www-data" /srv/repo

# Crear configuración de NGINX para el repositorio
NGINX_CONF="/etc/nginx/sites-available/repo"
sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    root /srv/repo;
    index index.html;

    autoindex on;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Activar configuración y reiniciar nginx
sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/repo
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

echo "✅ Repositorio listo en: http://$(hostname -I | awk '{print $1}')/"

echo "🔐 Instalando Certbot para certificados SSL..."
sudo apt install -y certbot python3-certbot-nginx

echo "🌐 Obteniendo certificado SSL para repository.rafex.app..."
sudo certbot --nginx --non-interactive --agree-tos --redirect -m rafex@rafex.dev -d repository.rafex.app

echo "✅ Certificado SSL instalado y NGINX configurado para HTTPS."