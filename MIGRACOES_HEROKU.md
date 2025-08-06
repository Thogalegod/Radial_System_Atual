# Correções de Migrações para Heroku

## Problemas Identificados e Corrigidos

### 1. **Ordem das Migrações**
- **Problema**: A migração `20250729205003_drop_rentals_table.rb` (que deleta a tabela rentals) vinha ANTES da migração `20250729204943_create_rentals.rb` (que cria a tabela rentals).
- **Solução**: Corrigida a migração de drop para usar métodos Rails padrão e adicionadas verificações de segurança.

### 2. **Uso de `execute` SQL Direto**
- **Problema**: Migração `20250729205003_drop_rentals_table.rb` usava `execute "DROP TABLE rentals CASCADE"` que pode não ser compatível com todos os ambientes.
- **Solução**: Substituído por `drop_table :rentals` do Rails.

### 3. **Dependências de Modelos Durante Migração**
- **Problema**: Migração `20250726175739_fix_equipment_feature_data_types.rb` referenciada modelos Rails (`EquipmentFeature`) durante a migração.
- **Solução**: Substituído por SQL direto usando `execute`.

### 4. **Migrações com `change` vs `up/down`**
- **Problema**: Várias migrações usavam `change` que pode não ser reversível em todos os casos.
- **Solução**: Convertidas para `up/down` com verificações de existência de tabelas.

### 5. **Extensões PostgreSQL**
- **Problema**: Extensões PostgreSQL não estavam sendo habilitadas corretamente.
- **Solução**: Criada migração `20250806000000_enable_postgresql_extensions.rb` para habilitar extensões necessárias.

## Migrações Corrigidas

### ✅ Migrações com `change` → `up/down`:
- `20250805205335_add_paid_date_to_financial_entries.rb`
- `20250730000429_add_remessa_note_to_rentals.rb`
- `20250729234412_add_client_order_and_observations_to_rental_billing_periods.rb`
- `20250729231858_remove_dates_from_rentals.rb`
- `20250729225443_remove_status_from_equipments.rb`
- `20250805233740_add_default_status_to_rentals.rb`

### ✅ Migrações com Verificações de Segurança:
- `20250729205003_drop_rentals_table.rb` - Adicionadas verificações de foreign keys
- `20250726175739_fix_equipment_feature_data_types.rb` - Removida dependência de modelos

### ✅ Nova Migração Criada:
- `20250806000000_enable_postgresql_extensions.rb` - Habilita extensões PostgreSQL

## Como Testar Localmente

### 1. Teste de Migrações
```bash
# Testar migrações em ambiente de desenvolvimento
ruby test_migrations.rb

# Testar migrações em ambiente de produção (simulado)
RAILS_ENV=production ruby test_migrations.rb
```

### 2. Reset e Migração Completa
```bash
# Reset completo do banco
rails db:drop db:create db:migrate db:seed

# Verificar status das migrações
rails db:migrate:status
```

## Deploy no Heroku

### Script Automatizado
```bash
./deploy_heroku.sh
```

### Deploy Manual
```bash
# 1. Login no Heroku
heroku login

# 2. Criar app (se necessário)
heroku create seu-app-name

# 3. Adicionar PostgreSQL
heroku addons:create heroku-postgresql:mini

# 4. Fazer deploy
git push heroku main

# 5. Executar migrações
heroku run rails db:migrate

# 6. Verificar status
heroku run rails db:migrate:status
```

## Troubleshooting

### Erro: "relation does not exist"
- **Causa**: Tabela não existe quando a migração tenta acessá-la
- **Solução**: Adicionadas verificações `if table_exists?(:table_name)` em todas as migrações

### Erro: "foreign key constraint"
- **Causa**: Tentativa de deletar tabela com foreign keys
- **Solução**: Remover foreign keys antes de deletar tabelas

### Erro: "extension not available"
- **Causa**: Extensões PostgreSQL não habilitadas
- **Solução**: Migração `20250806000000_enable_postgresql_extensions.rb` habilita extensões necessárias

### Erro: "model not found"
- **Causa**: Referência a modelos Rails durante migração
- **Solução**: Usar SQL direto em vez de modelos Rails

## Verificações Pós-Deploy

### 1. Verificar Logs
```bash
heroku logs --tail
```

### 2. Verificar Status das Migrações
```bash
heroku run rails db:migrate:status
```

### 3. Verificar Tabelas
```bash
heroku run rails console
# No console: ActiveRecord::Base.connection.tables
```

### 4. Testar Aplicação
```bash
heroku open
```

## Comandos Úteis

```bash
# Ver logs em tempo real
heroku logs --tail

# Reiniciar app
heroku restart

# Executar migrações
heroku run rails db:migrate

# Reset do banco (cuidado!)
heroku run rails db:reset

# Console Rails
heroku run rails console

# Status do app
heroku ps
```

## Próximos Passos

1. **Teste Local**: Execute `ruby test_migrations.rb` para verificar se tudo está funcionando
2. **Deploy**: Use `./deploy_heroku.sh` para fazer o deploy automatizado
3. **Monitoramento**: Acompanhe os logs durante o deploy
4. **Verificação**: Confirme que todas as migrações foram aplicadas corretamente

## Notas Importantes

- ✅ Todas as migrações agora usam métodos Rails seguros
- ✅ Verificações de existência de tabelas adicionadas
- ✅ Extensões PostgreSQL habilitadas corretamente
- ✅ Script de teste criado para validação local
- ✅ Script de deploy atualizado com verificações 