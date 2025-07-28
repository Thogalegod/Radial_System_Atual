#!/bin/bash

# Script para configurar backup automático do banco de dados
# Executar como: ./setup_backup_cron.sh

echo "🔧 Configurando backup automático do banco de dados..."

# Obter o diretório do projeto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$PROJECT_DIR/config/backup_schedule.rb"

# Verificar se o script de backup existe
if [ ! -f "$BACKUP_SCRIPT" ]; then
    echo "❌ Erro: Script de backup não encontrado em $BACKUP_SCRIPT"
    exit 1
fi

# Criar diretório de backups
mkdir -p "$PROJECT_DIR/backups"

# Configurar cron job para executar backup diariamente às 2:00 AM
CRON_JOB="0 2 * * * cd $PROJECT_DIR && bundle exec ruby $BACKUP_SCRIPT >> $PROJECT_DIR/backups/backup.log 2>&1"

# Verificar se o cron job já existe
if crontab -l 2>/dev/null | grep -q "$BACKUP_SCRIPT"; then
    echo "⚠️  Cron job já existe. Removendo entrada anterior..."
    crontab -l 2>/dev/null | grep -v "$BACKUP_SCRIPT" | crontab -
fi

# Adicionar novo cron job
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "✅ Backup automático configurado!"
echo "📅 Execução: Diariamente às 2:00 AM"
echo "📁 Diretório de backups: $PROJECT_DIR/backups"
echo "📝 Log: $PROJECT_DIR/backups/backup.log"

# Testar o script de backup
echo ""
echo "🧪 Testando script de backup..."
cd "$PROJECT_DIR"
bundle exec ruby "$BACKUP_SCRIPT"

if [ $? -eq 0 ]; then
    echo "✅ Teste de backup realizado com sucesso!"
else
    echo "❌ Erro no teste de backup. Verifique as configurações do banco."
fi

echo ""
echo "📋 Para verificar os cron jobs ativos:"
echo "   crontab -l"
echo ""
echo "📋 Para remover o backup automático:"
echo "   crontab -l | grep -v '$BACKUP_SCRIPT' | crontab -" 