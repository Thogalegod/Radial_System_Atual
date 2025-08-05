#!/usr/bin/env ruby

# Script para limpar migrations fantasmas da tabela schema_migrations
require_relative 'config/environment'

# Lista de timestamps das migrations fantasmas
phantom_migrations = [
  '20250728202957',
  '20250728203003',
  '20250728203008',
  '20250728203015', 
  '20250728203022',
  '20250728203028',
  '20250728205015',
  '20250728210957',
  '20250728212116',
  '20250728213837',
  '20250728214246',
  '20250728215231',
  '20250728225032',
  '20250728233030',
  '20250728233114',
  '20250728235059',
  '20250729170842',
  '20250729171128',
  '20250729171911',
  '20250729172118',
  '20250729202728',
  '20250729202732'
]

puts "Removendo migrations fantasmas da tabela schema_migrations..."

phantom_migrations.each do |version|
  result = ActiveRecord::Base.connection.execute(
    "DELETE FROM schema_migrations WHERE version = '#{version}'"
  )
  puts "Removida migration #{version}" if result.cmd_tuples > 0
end

puts "Limpeza concluída!"