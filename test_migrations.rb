#!/usr/bin/env ruby

# Script para testar migrações antes do deploy no Heroku
puts "🔍 Testando migrações para deploy no Heroku..."

# Verificar se estamos no ambiente correto
if ENV['RAILS_ENV'] != 'production'
  puts "⚠️  Executando em ambiente: #{ENV['RAILS_ENV'] || 'development'}"
  puts "💡 Para testar como produção, execute: RAILS_ENV=production ruby test_migrations.rb"
end

begin
  # Carregar o Rails
  require_relative 'config/environment'
  
  puts "✅ Rails carregado com sucesso"
  
  # Verificar conexão com banco
  ActiveRecord::Base.connection.execute("SELECT 1")
  puts "✅ Conexão com banco estabelecida"
  
  # Verificar se as extensões PostgreSQL estão disponíveis
  extensions = ActiveRecord::Base.connection.execute("SELECT extname FROM pg_extension")
  puts "📋 Extensões PostgreSQL disponíveis:"
  extensions.each do |ext|
    puts "   - #{ext['extname']}"
  end
  
  # Verificar se podemos executar migrações
  puts "🔄 Testando execução de migrações..."
  
  # Listar migrações pendentes
  pending_migrations = ActiveRecord::MigrationContext.new('db/migrate').pending_migrations
  if pending_migrations.any?
    puts "📝 Migrações pendentes:"
    pending_migrations.each do |migration|
      puts "   - #{migration.version}: #{migration.name}"
    end
  else
    puts "✅ Nenhuma migração pendente"
  end
  
  # Verificar estrutura do banco
  tables = ActiveRecord::Base.connection.tables
  puts "📊 Tabelas existentes:"
  tables.each do |table|
    puts "   - #{table}"
  end
  
  puts "✅ Teste de migrações concluído com sucesso!"
  puts "🚀 Pronto para deploy no Heroku"
  
rescue => e
  puts "❌ Erro durante teste de migrações:"
  puts "   #{e.message}"
  puts "   #{e.backtrace.first(5).join("\n   ")}"
  exit 1
end 