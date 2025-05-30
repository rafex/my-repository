#!/bin/sh
set -eu

echo "🌐 Configurando locale del sistema a es_MX.UTF-8..."

# Descomentar es_MX.UTF-8 si está comentado
sudo sed -i 's/^# *\(es_MX.UTF-8 UTF-8\)/\1/' /etc/locale.gen

# Generar locales
sudo locale-gen

# Establecer locale por defecto en minúsculas (como lo espera update-locale)
sudo update-locale LANG=es_MX.utf8

# Aplicar temporalmente para la sesión actual
echo "export LANG=es_MX.utf8" | sudo tee /etc/profile.d/locale.sh
echo "export LANGUAGE=es_MX:es" | sudo tee -a /etc/profile.d/locale.sh
echo "export LC_ALL=es_MX.UTF-8" | sudo tee -a /etc/profile.d/locale.sh
sudo chmod +x /etc/profile.d/locale.sh

echo "✅ Locale configurado a es_MX.UTF-8"

# Configurar terminal
echo "🎨 Configurando tipo de terminal a xterm-256color..."
echo "export TERM=xterm-256color" | sudo tee /etc/profile.d/term.sh
sudo chmod +x /etc/profile.d/term.sh

echo "✅ Configuración del servidor completada."

echo "🕒 Configurando zona horaria a America/Mexico_City..."
sudo ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
sudo dpkg-reconfigure -f noninteractive tzdata
echo "✅ Zona horaria configurada a $(date)"