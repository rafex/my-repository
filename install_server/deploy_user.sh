#!/bin/sh
set -e

USER="githubdeploy"
SSH_DIR="/home/$USER/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

echo "👤 Creando usuario $USER..."
sudo adduser --disabled-password --gecos "" --shell /usr/bin/sh "$USER"

echo "📁 Creando carpeta SSH..."
sudo mkdir -p "$SSH_DIR"
sudo chmod 700 "$SSH_DIR"
sudo chown "$USER:$USER" "$SSH_DIR"

echo "🔑 Pegando clave pública autorizada..."
if [ -t 0 ]; then
  if [ -z "$1" ]; then
    echo "❌ Debes pasar la clave pública como argumento o por stdin."
    exit 1
  fi
  echo "command=\"/bin/false\",no-agent-forwarding,no-X11-forwarding,no-port-forwarding $1" | sudo tee "$AUTHORIZED_KEYS" > /dev/null
else
  read -r KEY
  echo "command=\"/bin/false\",no-agent-forwarding,no-X11-forwarding,no-port-forwarding $KEY" | sudo tee "$AUTHORIZED_KEYS" > /dev/null
fi

sudo chmod 600 "$AUTHORIZED_KEYS"
sudo chown "$USER:$USER" "$AUTHORIZED_KEYS"

sudo chown githubdeploy:www-data /srv/repo/debian/dists/stable/main/binary-*
echo "✅ Usuario $USER configurado correctamente con acceso SSH."