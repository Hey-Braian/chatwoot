# 🚀 Guía de Configuración de Entorno de Desarrollo - Chatwoot

Esta documentación te guiará paso a paso para configurar el entorno de desarrollo local de Chatwoot en Ubuntu 24.04.

## 📋 Requisitos Previos

- Ubuntu 24.04 LTS (recomendado)
- Conexión a Internet
- Permisos de sudo en el sistema
- Git instalado

## 🛠️ Paso 1: Actualizar el Sistema

```bash
sudo apt update && sudo apt upgrade -y
```

## 🔧 Paso 2: Instalar Dependencias Básicas

### Instalar herramientas de desarrollo y librerías

```bash
sudo apt install -y git software-properties-common ca-certificates imagemagick libpq-dev \
libxml2-dev libxslt1-dev file g++ gcc autoconf build-essential libssl-dev libyaml-dev \
libreadline-dev gnupg2 patch ruby-dev zlib1g-dev liblzma-dev libgmp-dev libncurses-dev \
libffi-dev libgdbm6t64 libgdbm-dev libvips42t64 python3-pip curl
```

## 📦 Paso 3: Instalar Node.js 23

### Agregar repositorio de NodeSource

```bash
# Agregar clave GPG
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

# Agregar repositorio
NODE_MAJOR=23
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# Actualizar e instalar Node.js
sudo apt update && sudo apt install -y nodejs

# Instalar pnpm globalmente
sudo npm install -g pnpm
```

### Verificar instalación

```bash
node --version  # Debe mostrar v23.x.x
npm --version   # Debe mostrar 10.x.x
pnpm --version  # Debe mostrar 9.x.x
```

## 💎 Paso 4: Instalar Ruby con RVM

### Instalar RVM (Ruby Version Manager)

```bash
# Instalar claves GPG para RVM
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

# Instalar RVM
curl -sSL https://get.rvm.io | bash -s stable

# Cargar RVM en la sesión actual
source ~/.rvm/scripts/rvm
```

### Instalar Ruby 3.4.4

```bash
# Instalar Ruby 3.4.4
rvm install "ruby-3.4.4"

# Configurar como versión por defecto
rvm use "3.4.4" --default

# Verificar instalación
ruby --version  # Debe mostrar ruby 3.4.4
```

**📝 Nota:** Agrega `source ~/.rvm/scripts/rvm` a tu `~/.bashrc` o `~/.zshrc` para cargar RVM automáticamente:

```bash
echo 'source ~/.rvm/scripts/rvm' >> ~/.bashrc
```

## 🗄️ Paso 5: Instalar PostgreSQL 16

### Agregar repositorio oficial de PostgreSQL

```bash
# Agregar clave GPG
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Agregar repositorio
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# Actualizar repositorios
sudo apt update
```

### Instalar PostgreSQL 16

```bash
sudo apt install -y postgresql-16 postgresql-16-pgvector postgresql-contrib postgresql-client-16
```

### Configurar PostgreSQL para desarrollo

```bash
# Crear usuario de PostgreSQL
sudo -u postgres createuser -s $USER

# Configurar autenticación local (para desarrollo)
sudo cp /etc/postgresql/16/main/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf.backup

# Permitir conexiones locales sin contraseña
sudo sed -i 's/local   all             all                                     peer/local   all             all                                     trust/' /etc/postgresql/16/main/pg_hba.conf
sudo sed -i 's/host    all             all             127.0.0.1\/32            scram-sha-256/host    all             all             127.0.0.1\/32            trust/' /etc/postgresql/16/main/pg_hba.conf

# Reiniciar PostgreSQL
sudo systemctl restart postgresql
sudo systemctl enable postgresql
```

### Verificar instalación

```bash
psql --version  # Debe mostrar PostgreSQL 16.x
createdb test_db && dropdb test_db  # Debe ejecutarse sin errores
```

## 🔴 Paso 6: Instalar Redis

### Agregar repositorio de Redis

```bash
# Agregar clave GPG
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

# Agregar repositorio
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

# Actualizar e instalar Redis
sudo apt update
sudo apt install -y redis-server redis-tools
```

### Iniciar Redis

```bash
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Verificar que Redis funciona
redis-cli ping  # Debe responder "PONG"
```

## 📁 Paso 7: Clonar el Repositorio

```bash
# Navegar al directorio home
cd ~

# Clonar el repositorio del proyecto
git clone https://github.com/Hey-Braian/chatwoot.git

# Entrar al directorio del proyecto
cd chatwoot
```

## 🔧 Paso 8: Instalar Dependencias del Proyecto

### Cargar RVM y instalar gems de Ruby

```bash
# Asegurarse de que RVM está cargado
source ~/.rvm/scripts/rvm

# Instalar dependencias de Ruby
bundle install
```

### Instalar dependencias de JavaScript

```bash
# Instalar dependencias con pnpm
pnpm install
```

## 🗃️ Paso 9: Configurar Variables de Entorno

### Crear archivo de configuración

```bash
# Copiar archivo de ejemplo
cp .env.example .env
```

### Editar el archivo `.env` con la configuración de desarrollo

```bash
# Usar tu editor preferido (nano, vim, code, etc.)
nano .env
```

**Contenido del archivo `.env` para desarrollo:**

```env
# =======================================================================
# CONFIGURACIÓN PARA DESARROLLO LOCAL
# =======================================================================

# Database
POSTGRES_DATABASE=chatwoot_development
POSTGRES_USERNAME=tu_usuario_del_sistema
POSTGRES_PASSWORD=
POSTGRES_HOST=localhost
POSTGRES_PORT=5432

# Redis
REDIS_URL=redis://localhost:6379

# Rails
RAILS_ENV=development
SECRET_KEY_BASE=84cc6d4b094a9e96f1ddcd7b8b2de6e6a4db8a4a4e3d85ec02a9d0b4e3b7d829

# Frontend URL
FRONTEND_URL=http://localhost:3000

# Force SSL (desactivado para desarrollo local)
FORCE_SSL=false

# ActiveStorage
ACTIVE_STORAGE_SERVICE=local

# Logs
RAILS_LOG_LEVEL=debug

# Otros
ENABLE_ACCOUNT_SIGNUP=true
```

**📝 Nota:** Reemplaza `tu_usuario_del_sistema` con tu nombre de usuario de Linux (puedes obtenerlo con `whoami`).

## 🏗️ Paso 10: Configurar Base de Datos

### Crear y preparar la base de datos

```bash
# Crear base de datos
createdb chatwoot_development

# Ejecutar migraciones
bundle exec rails db:migrate

# Cargar datos iniciales (opcional, puede fallar si ya existen)
bundle exec rails db:seed
```

### Configurar usuario de acceso

```bash
# Crear/actualizar usuario con credenciales conocidas
bundle exec rails runner "
user = User.find_or_create_by(email: 'admin@chatwoot.local') do |u|
  u.name = 'Administrador'
  u.password = 'Balcami123_'
  u.password_confirmation = 'Balcami123_'
end
user.update!(password: 'Balcami123_', password_confirmation: 'Balcami123_')
puts '✅ Usuario configurado: admin@chatwoot.local / Balcami123_'
"
```

## 🚀 Paso 11: Iniciar el Entorno de Desarrollo

### Terminal 1: Servidor Rails (Backend)

```bash
cd ~/chatwoot
source ~/.rvm/scripts/rvm
bundle exec rails server -p 3000 -b 0.0.0.0
```

### Terminal 2: Servidor Vite (Frontend Assets)

```bash
cd ~/chatwoot
source ~/.rvm/scripts/rvm
bundle exec vite dev
```

### Acceder a la aplicación

1. **Abrir navegador en:** `http://localhost:3000`
2. **Credenciales de acceso:**
   - Email: `admin@chatwoot.local`
   - Contraseña: `Balcami123_`

## 🔄 Comandos de Uso Diario

### Iniciar servicios

```bash
# Iniciar PostgreSQL y Redis (si no están corriendo)
sudo systemctl start postgresql
sudo systemctl start redis-server

# Verificar estado
sudo systemctl status postgresql
sudo systemctl status redis-server
```

### Comandos útiles de desarrollo

```bash
# Consola de Rails
bundle exec rails console

# Ejecutar tests
bundle exec rspec

# Ver rutas disponibles
bundle exec rails routes

# Generar nuevos componentes
bundle exec rails generate model NombreModelo
bundle exec rails generate controller NombreController

# Migraciones
bundle exec rails generate migration NombreMigracion
bundle exec rails db:migrate
bundle exec rails db:rollback

# Resetear base de datos completa
bundle exec rails db:drop db:create db:migrate db:seed
```

### Gestión de usuarios

```bash
# Listar usuarios existentes
bundle exec rails runner "User.all.each { |u| puts \"ID: #{u.id} - Email: #{u.email} - Nombre: #{u.name}\" }"

# Crear nuevo usuario
bundle exec rails runner "
User.create!(
  email: 'nuevo@ejemplo.com',
  password: 'contraseña123',
  password_confirmation: 'contraseña123',
  name: 'Nombre Usuario'
)
"

# Cambiar contraseña de usuario existente
bundle exec rails runner "
user = User.find_by(email: 'email_usuario')
user.update!(password: 'nueva_contraseña', password_confirmation: 'nueva_contraseña')
puts 'Contraseña actualizada'
"
```

## 📂 Estructura del Proyecto

- **`app/`** - Código principal de la aplicación Rails
  - `models/` - Modelos de datos
  - `controllers/` - Controladores
  - `javascript/` - Código frontend Vue.js
  - `views/` - Vistas de Rails
- **`config/`** - Configuración de la aplicación
- **`db/`** - Migraciones y seeds de base de datos
- **`spec/`** - Tests con RSpec
- **`public/`** - Assets públicos

## 🔄 Flujo de Trabajo Git

```bash
# Crear nueva rama para feature
git checkout -b feature/nueva-funcionalidad

# Hacer cambios y commit
git add .
git commit -m "Descripción de cambios"

# Subir cambios a tu repositorio
git push origin feature/nueva-funcionalidad

# Crear Pull Request en GitHub
```

## 🐛 Solución de Problemas Comunes

### Error: "Command 'bundle' not found"

```bash
# Cargar RVM y verificar Ruby
source ~/.rvm/scripts/rvm
ruby --version
gem install bundler
```

### Error de conexión a PostgreSQL

```bash
# Verificar que PostgreSQL está corriendo
sudo systemctl status postgresql

# Verificar configuración de autenticación
sudo nano /etc/postgresql/16/main/pg_hba.conf
sudo systemctl reload postgresql
```

### Error de conexión a Redis

```bash
# Verificar que Redis está corriendo
sudo systemctl status redis-server

# Reiniciar Redis si es necesario
sudo systemctl restart redis-server
```

### Puerto 3000 ocupado

```bash
# Encontrar proceso usando el puerto
sudo lsof -i :3000

# Terminar proceso (reemplaza PID con el número del proceso)
kill -9 PID

# O usar otro puerto
bundle exec rails server -p 3001
```

## 📞 Contacto y Soporte

Para dudas o problemas durante la configuración, contacta al equipo de desarrollo.

---

**¡Feliz desarrollo! 🎉**

> **Nota:** Esta guía está optimizada para Ubuntu 24.04. Para otros sistemas operativos, algunos comandos pueden variar.
