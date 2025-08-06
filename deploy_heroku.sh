#!/bin/bash

echo "🚀 Iniciando deploy para o Heroku..."

# Verificar se o Heroku CLI está instalado
if ! command -v heroku &> /dev/null; then
    echo "❌ Heroku CLI não está instalado. Por favor, instale primeiro:"
    echo "   curl https://cli-assets.heroku.com/install.sh | sh"
    exit 1
fi

# Verificar se está logado no Heroku
if ! heroku auth:whoami &> /dev/null; then
    echo "🔐 Faça login no Heroku:"
    heroku login
fi

# Nome do app no Heroku (você pode alterar isso)
APP_NAME="radial-system-$(date +%s)"

echo "📦 Criando app no Heroku: $APP_NAME"

# Criar o app no Heroku
heroku create $APP_NAME

# Adicionar buildpack do Ruby
heroku buildpacks:add heroku/ruby

# Configurar variáveis de ambiente
heroku config:set RAILS_ENV=production
heroku config:set RAILS_SERVE_STATIC_FILES=true
heroku config:set RAILS_LOG_TO_STDOUT=true

# Adicionar banco PostgreSQL
echo "🗄️ Adicionando banco PostgreSQL..."
heroku addons:create heroku-postgresql:mini

# Aguardar um pouco para o banco ser criado
echo "⏳ Aguardando criação do banco de dados..."
sleep 10

# Fazer commit das mudanças se necessário
if ! git diff --quiet; then
    echo "📝 Fazendo commit das mudanças..."
    git add .
    git commit -m "Configuração para deploy no Heroku"
fi

# Fazer push para o Heroku
echo "🚀 Fazendo push para o Heroku..."
git push heroku main

# Verificar se o app está funcionando
echo "🔍 Verificando status do app..."
heroku ps

# Executar migrações com verificação
echo "🗄️ Executando migrações do banco de dados..."
if heroku run rails db:migrate; then
    echo "✅ Migrações executadas com sucesso!"
else
    echo "❌ Erro nas migrações. Verificando logs..."
    heroku logs --tail
    echo "🔄 Tentando reset do banco..."
    heroku run rails db:reset
fi

# Verificar se as migrações foram aplicadas
echo "🔍 Verificando status das migrações..."
heroku run rails db:migrate:status

# Abrir o app
echo "🌐 Abrindo o app..."
heroku open

echo "✅ Deploy concluído! Seu app está disponível em:"
heroku info -s | grep web_url | cut -d= -f2

echo ""
echo "📋 Comandos úteis:"
echo "   heroku logs --tail          # Ver logs em tempo real"
echo "   heroku run rails console    # Abrir console Rails"
echo "   heroku run rails db:migrate # Executar migrações"
echo "   heroku restart              # Reiniciar app" 