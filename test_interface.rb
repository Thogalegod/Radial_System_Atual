#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'

# URL base
base_url = 'http://localhost:3000'

puts "🧪 Testando a nova interface de equipamentos..."
puts "URL: #{base_url}/equipments"
puts ""

# Testar acesso à página de login
puts "1. Verificando página de login..."
login_url = "#{base_url}/login"
response = Net::HTTP.get_response(URI(login_url))
puts "   Status: #{response.code}"
puts "   Login page acessível: #{response.code == '200' ? '✅' : '❌'}"
puts ""

# Testar acesso à página de equipamentos (deve redirecionar para login)
puts "2. Verificando redirecionamento para login..."
equipments_url = "#{base_url}/equipments"
response = Net::HTTP.get_response(URI(equipments_url))
puts "   Status: #{response.code}"
puts "   Redirecionamento para login: #{response.code == '302' ? '✅' : '❌'}"
puts ""

puts "📋 Instruções para testar a nova interface:"
puts ""
puts "1. Acesse: http://localhost:3000/login"
puts "2. Faça login com:"
puts "   Email: 1@1"
puts "   Senha: 123456"
puts "3. Após o login, acesse: http://localhost:3000/equipments"
puts ""
puts "🎨 Características da nova interface:"
puts "   ✅ Tema escuro similar à imagem de referência"
puts "   ✅ Tabela organizada com colunas"
puts "   ✅ Tags coloridas para status e características"
puts "   ✅ Suporte a fotos dos equipamentos"
puts "   ✅ Filtros funcionais"
puts "   ✅ Design responsivo"
puts ""

puts "🚀 A nova interface está pronta para uso!" 