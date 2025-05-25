#!/bin/sh

set -e

usage() {
  echo "Uso: $0 [OPCIÓN]"
  echo ""
  echo "Opciones:"
  echo "  --create-sign   Crear la clave GPG, exportarla y firmar todos los paquetes .deb"
  echo "  --sign          Firmar únicamente los paquetes .deb existentes"
  echo "  --reindex       Regenerar Packages.gz y firmar el archivo Release"
  exit 1
}

if [ $# -eq 0 ]; then
  usage
fi

# 🔐 Parámetros de la clave
NAME="Raúl GPG Repo"
EMAIL="rafex@rafex.dev"
KEYFILE="rafex-repo.asc"
KEYID_FILE="rafex-keyid.txt"

# 📁 Directorio del repo
REPO_PATH="/srv/repo/debian"
ARCHS="amd64 arm64"

case "$1" in
  --create-sign)
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

    KEYID=$(gpg --list-keys --with-colons "$EMAIL" | awk -F: '/^pub/ {print $5}')
    echo "$KEYID" > "$KEYID_FILE"

    echo "📤 Exportando clave pública a $KEYFILE..."
    gpg --armor --export "$KEYID" > "$KEYFILE"
    ;;

  --sign)
    [ -f "$KEYID_FILE" ] || { echo "❌ No se encontró $KEYID_FILE. Ejecuta --create-sign primero."; exit 1; }
    KEYID=$(cat "$KEYID_FILE")
    echo "📝 Firmando paquetes .deb con clave $KEYID..."
    for ARCH in $ARCHS; do
      cd "$REPO_PATH/dists/stable/main/binary-$ARCH"
      for DEB in *.deb; do
        dpkg-sig --sign builder "$DEB"
      done
    done
    ;;

  --reindex)
    echo "📦 Regenerando índice Packages.gz..."
    for ARCH in $ARCHS; do
      DIR="$REPO_PATH/dists/stable/main/binary-$ARCH"
      [ -d "$DIR" ] && {
        cd "$DIR"
        dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
        echo "✅ $ARCH: Packages.gz generado"
      }
    done

    echo "🧾 Firmando Release..."
    cd "$REPO_PATH/dists/stable"
    apt-ftparchive release . > Release
    KEYID=$(cat "$KEYID_FILE")
    gpg --default-key "$KEYID" -abs -o Release.gpg Release
    gpg --default-key "$KEYID" --clearsign -o InRelease Release
    ;;

  *)
    usage
    ;;
esac