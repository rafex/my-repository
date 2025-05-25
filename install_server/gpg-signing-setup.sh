#!/bin/sh

set -e

# 🔐 Parámetros de la clave
NAME="Raúl GPG Repo"
EMAIL="rafex@rafex.dev"
KEYFILE="rafex-repo.asc"
KEYID_FILE="rafex-keyid.txt"

# 📁 Directorio del repo
REPO_PATH="/srv/repo/debian"
ARCHS="amd64 arm64"

echo "🔐 Creando clave GPG..."
cat >keyconfig <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Name-Real: $NAME
Name-Email: $EMAIL
Expire-Date: 0
%commit
EOF

gpg --batch --gen-key keyconfig
rm keyconfig

# 📋 Obtener ID de la clave generada
KEYID=$(gpg --list-keys --with-colons "$EMAIL" | awk -F: '/^pub/ {print $5}')
echo "$KEYID" > "$KEYID_FILE"

echo "📤 Exportando clave pública a $KEYFILE..."
gpg --armor --export "$KEYID" > "$KEYFILE"

echo "📝 Firmando paquetes .deb..."
for ARCH in $ARCHS; do
  cd "$REPO_PATH/dists/stable/main/binary-$ARCH"
  for DEB in *.deb; do
    dpkg-sig --sign builder "$DEB"
  done
done

echo "🧾 Firmando Release..."
cd "$REPO_PATH/dists/stable"
apt-ftparchive release . > Release
gpg --default-key "$KEYID" -abs -o Release.gpg Release
gpg --default-key "$KEYID" --clearsign -o InRelease Release

echo "✅ Repositorio firmado. Clave pública: $KEYFILE"