#!/bin/bash

# 🚀 Script de Instalación Automática - Chatwoot Development Environment
# Para Ubuntu 24.04 LTS

set -e  # Salir si cualquier comando falla

echo "🚀 Iniciando configuración de entorno de desarrollo Chatwoot..."
echo "📋 Este script instalará todas las dependencias necesarias."
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar si es Ubuntu 24.04
if [[ ! -f /etc/os-release ]] || ! grep -q "Ubuntu 24.04" /etc/os-release; then
    print_warning "Este script está optimizado para Ubuntu 24.04. Otros sistemas pueden requerir ajustes."
fi

# Actualizar sistema
echo "📦 Actualizando sistema..."
sudo apt update && sudo apt upgrade -y
print_status "Sistema actualizado"

# Instalar dependencias básicas
echo "🔧 Instalando dependencias básicas..."
sudo apt install -y git software-properties-common ca-certificates imagemagick libpq-dev \
libxml2-dev libxslt1-dev file g++ gcc autoconf build-essential libssl-dev libyaml-dev \
libreadline-dev gnupg2 patch ruby-dev zlib1g-dev liblzma-dev libgmp-dev libncurses-dev \
libffi-dev libgdbm6t64 libgdbm-dev libvips42t64 python3-pip curl
print_status "Dependencias básicas instaladas"

# Instalar Node.js 23
echo "📦 Instalando Node.js 23..."
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=23
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update && sudo apt install -y nodejs
sudo npm install -g pnpm
print_status "Node.js 23 y pnpm instalados"

# Instalar RVM y Ruby
echo "💎 Instalando RVM y Ruby 3.4.4..."
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install "ruby-3.4.4"
rvm use "3.4.4" --default
print_status "Ruby 3.4.4 instalado con RVM"

# Instalar PostgreSQL 16
echo "🗄️ Instalando PostgreSQL 16..."
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
sudo apt update
sudo apt install -y postgresql-16 postgresql-16-pgvector postgresql-contrib postgresql-client-16

# Configurar PostgreSQL
echo "⚙️ Configurando PostgreSQL..."
sudo -u postgres createuser -s $USER
sudo cp /etc/postgresql/16/main/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf.backup
sudo sed -i 's/local   all             all                                     peer/local   all             all                                     trust/' /etc/postgresql/16/main/pg_hba.conf
sudo sed -i 's/host    all             all             127.0.0.1\/32            scram-sha-256/host    all             all             127.0.0.1\/32            trust/' /etc/postgresql/16/main/pg_hba.conf
sudo systemctl restart postgresql
sudo systemctl enable postgresql
print_status "PostgreSQL 16 configurado"

# Instalar Redis
echo "🔴 Instalando Redis..."
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt update
sudo apt install -y redis-server redis-tools
sudo systemctl start redis-server
sudo systemctl enable redis-server
print_status "Redis instalado y configurado"

# Verificar si ya existe el directorio chatwoot
if [ -d "$HOME/chatwoot" ]; then
    print_warning "El directorio ~/chatwoot ya existe. ¿Deseas eliminar y clonar de nuevo? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/chatwoot"
        print_status "Directorio anterior eliminado"
    else
        print_warning "Usando directorio existente"
    fi
fi

# Clonar repositorio si no existe
if [ ! -d "$HOME/chatwoot" ]; then
    echo "📁 Clonando repositorio..."
    cd ~
    git clone https://github.com/Hey-Braian/chatwoot.git
    print_status "Repositorio clonado"
fi

cd ~/chatwoot

# Configurar variables de entorno
echo "🗃️ Configurando variables de entorno..."
cat > .env << ENVEOF
# Configuración para desarrollo local
POSTGRES_DATABASE=chatwoot_development
POSTGRES_USERNAME=$(whoami)
POSTGRES_PASSWORD=
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
REDIS_URL=redis://localhost:6379
RAILS_ENV=development
SECRET_KEY_BASE=84cc6d4b094a9e96f1ddcd7b8b2de6e6a4db8a4a4e3d85ec02a9d0b4e3b7d829
FRONTEND_URL=http://localhost:3000
FORCE_SSL=false
ACTIVE_STORAGE_SERVICE=local
RAILS_LOG_LEVEL=debug
ENABLE_ACCOUNT_SIGNUP=true
ENVEOF
print_status "Variables de entorno configuradas"

# Instalar dependencias del proyecto
echo "📦 Instalando dependencias del proyecto..."
source ~/.rvm/scripts/rvm
bundle install
print_status "Dependencias de Ruby instaladas"

pnpm install
print_status "Dependencias de JavaScript instaladas"

# Configurar base de datos
echo "🏗️ Configurando base de datos..."
createdb chatwoot_development 2>/dev/null || print_warning "La base de datos ya existe"
bundle exec rails db:migrate
print_status "Migraciones ejecutadas"

# Configurar usuario de acceso
echo "👤 Configurando usuario de acceso..."
bundle exec rails runner "
user = User.find_or_create_by(email: 'admin@chatwoot.local') do |u|
  u.name = 'Administrador'
  u.password = 'Balcami123_'
  u.password_confirmation = 'Balcami123_'
end
user.update!(password: 'Balcami123_', password_confirmation: 'Balcami123_')
puts '✅ Usuario configurado: admin@chatwoot.local / Balcami123_'
"
print_status "Usuario de acceso configurado"

# Agregar RVM al bashrc si no está
if ! grep -q "source ~/.rvm/scripts/rvm" ~/.bashrc; then
    echo 'source ~/.rvm/scripts/rvm' >> ~/.bashrc
    print_status "RVM agregado a ~/.bashrc"
fi

echo ""
echo "🎉 ¡Instalación completada exitosamente!"
echo ""
echo "�� INFORMACIÓN DE ACCESO:"
echo "=========================="
echo "URL: http://localhost:3000"
echo "Email: admin@chatwoot.local"
echo "Contraseña: Balcami123_"
echo ""
echo "🚀 PARA INICIAR EL SERVIDOR:"
echo "============================="
echo "Terminal 1 (Backend):"
echo "cd ~/chatwoot"
echo "source ~/.rvm/scripts/rvm"
echo "bundle exec rails server -p 3000 -b 0.0.0.0"
echo ""
echo "Terminal 2 (Frontend):"
echo "cd ~/chatwoot"
echo "source ~/.rvm/scripts/rvm"
echo "bundle exec vite dev"
echo ""
echo "💡 CONSEJOS:"
echo "============"
echo "- Reinicia tu terminal o ejecuta 'source ~/.bashrc' para cargar RVM automáticamente"
echo "- Los servicios PostgreSQL y Redis se inician automáticamente al arrancar el sistema"
echo "- Revisa SETUP_DESARROLLO.md para documentación completa"
echo ""
print_status "¡Listo para desarrollar!"
