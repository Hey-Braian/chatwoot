# ⚡ Configuración Rápida - Chatwoot Dev

## 🚀 Script de Instalación Automática

```bash
#!/bin/bash
# Script de instalación automática para Ubuntu 24.04

# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
sudo apt install -y git software-properties-common ca-certificates imagemagick libpq-dev \
libxml2-dev libxslt1-dev file g++ gcc autoconf build-essential libssl-dev libyaml-dev \
libreadline-dev gnupg2 patch ruby-dev zlib1g-dev liblzma-dev libgmp-dev libncurses-dev \
libffi-dev libgdbm6t64 libgdbm-dev libvips42t64 python3-pip curl

# Instalar Node.js 23
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=23
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update && sudo apt install -y nodejs
sudo npm install -g pnpm

# Instalar RVM y Ruby
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install "ruby-3.4.4"
rvm use "3.4.4" --default

# Instalar PostgreSQL 16
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
sudo apt update
sudo apt install -y postgresql-16 postgresql-16-pgvector postgresql-contrib postgresql-client-16

# Configurar PostgreSQL
sudo -u postgres createuser -s $USER
sudo cp /etc/postgresql/16/main/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf.backup
sudo sed -i 's/local   all             all                                     peer/local   all             all                                     trust/' /etc/postgresql/16/main/pg_hba.conf
sudo sed -i 's/host    all             all             127.0.0.1\/32            scram-sha-256/host    all             all             127.0.0.1\/32            trust/' /etc/postgresql/16/main/pg_hba.conf
sudo systemctl restart postgresql
sudo systemctl enable postgresql

# Instalar Redis
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt update
sudo apt install -y redis-server redis-tools
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Clonar repositorio
cd ~
git clone https://github.com/Hey-Braian/chatwoot.git
cd chatwoot

# Configurar variables de entorno
cat > .env << 'ENVEOF'
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

# Instalar dependencias del proyecto
source ~/.rvm/scripts/rvm
bundle install
pnpm install

# Configurar base de datos
createdb chatwoot_development
bundle exec rails db:migrate
bundle exec rails runner "
user = User.find_or_create_by(email: 'admin@chatwoot.local') do |u|
  u.name = 'Administrador'
  u.password = 'Balcami123_'
  u.password_confirmation = 'Balcami123_'
end
user.update!(password: 'Balcami123_', password_confirmation: 'Balcami123_')
puts '✅ Usuario configurado: admin@chatwoot.local / Balcami123_'
"

echo "🎉 ¡Instalación completada!"
echo "Para iniciar el servidor:"
echo "cd ~/chatwoot"
echo "source ~/.rvm/scripts/rvm"
echo "bundle exec rails server -p 3000 -b 0.0.0.0"
echo ""
echo "Acceso: http://localhost:3000"
echo "Email: admin@chatwoot.local"
echo "Contraseña: Balcami123_"
```

## 🏃‍♂️ Comandos de Inicio Rápido

### Iniciar desarrollo (ejecutar en 2 terminales)

**Terminal 1 - Backend:**
```bash
cd ~/chatwoot
source ~/.rvm/scripts/rvm
bundle exec rails server -p 3000 -b 0.0.0.0
```

**Terminal 2 - Frontend:**
```bash
cd ~/chatwoot
source ~/.rvm/scripts/rvm
bundle exec vite dev
```

### Acceso
- **URL:** http://localhost:3000
- **Email:** admin@chatwoot.local
- **Contraseña:** Balcami123_

## 🔧 Comandos Útiles

```bash
# Listar usuarios
bundle exec rails runner "User.all.each { |u| puts \"#{u.email} - #{u.name}\" }"

# Cambiar contraseña
bundle exec rails runner "User.find_by(email: 'admin@chatwoot.local').update!(password: 'nueva_pass', password_confirmation: 'nueva_pass')"

# Resetear DB
bundle exec rails db:drop db:create db:migrate db:seed

# Consola Rails
bundle exec rails console

# Tests
bundle exec rspec
```
