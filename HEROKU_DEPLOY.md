# Deploy no Heroku - Radial System

## Pré-requisitos

1. **Conta no Heroku**: Crie uma conta em [heroku.com](https://heroku.com)
2. **Heroku CLI**: Instale o Heroku CLI
   ```bash
   curl https://cli-assets.heroku.com/install.sh | sh
   ```
3. **Git**: Certifique-se de que o projeto está em um repositório Git

## Configurações Realizadas

✅ **Arquivos criados/modificados:**
- `app.json` - Configuração do app Heroku
- `.ruby-version` - Versão do Ruby (3.4.5)
- `deploy_heroku.sh` - Script automatizado de deploy
- `Gemfile` - Adicionado suporte ao SQLite3 para desenvolvimento
- `config/environments/production.rb` - Configurações otimizadas para produção

## Deploy Automatizado

### Opção 1: Usar o script automatizado
```bash
./deploy_heroku.sh
```

### Opção 2: Deploy manual

1. **Login no Heroku:**
   ```bash
   heroku login
   ```

2. **Criar o app:**
   ```bash
   heroku create seu-app-name
   ```

3. **Configurar buildpack:**
   ```bash
   heroku buildpacks:add heroku/ruby
   ```

4. **Configurar variáveis de ambiente:**
   ```bash
   heroku config:set RAILS_ENV=production
   heroku config:set RAILS_SERVE_STATIC_FILES=true
   heroku config:set RAILS_LOG_TO_STDOUT=true
   ```

5. **Adicionar banco PostgreSQL:**
   ```bash
   heroku addons:create heroku-postgresql:mini
   ```

6. **Fazer deploy:**
   ```bash
   git push heroku main
   ```

7. **Executar migrações:**
   ```bash
   heroku run rails db:migrate
   ```

8. **Abrir o app:**
   ```bash
   heroku open
   ```

## Verificações Pós-Deploy

### Logs
```bash
heroku logs --tail
```

### Status do app
```bash
heroku ps
```

### Configurações
```bash
heroku config
```

### Console Rails
```bash
heroku run rails console
```

## Troubleshooting

### Problema: App não inicia
- Verifique os logs: `heroku logs --tail`
- Verifique se o banco foi criado: `heroku addons:open postgresql`

### Problema: Erro de migração
- Execute: `heroku run rails db:migrate`
- Se necessário: `heroku run rails db:reset`

### Problema: Assets não carregam
- Verifique se `RAILS_SERVE_STATIC_FILES=true`
- Execute: `heroku run rails assets:precompile`

## Comandos Úteis

```bash
# Ver logs em tempo real
heroku logs --tail

# Reiniciar o app
heroku restart

# Ver informações do app
heroku info

# Abrir o app no navegador
heroku open

# Executar comando no servidor
heroku run rails console
heroku run rails db:migrate
```

## Configurações de Domínio

Para usar um domínio personalizado:
```bash
heroku domains:add www.seudominio.com
```

## Monitoramento

- **Logs**: `heroku logs --tail`
- **Métricas**: Dashboard do Heroku
- **Alertas**: Configure no dashboard do Heroku

## Segurança

- As credenciais do banco são gerenciadas automaticamente pelo Heroku
- Use `heroku config:set` para variáveis sensíveis
- Nunca commite arquivos `.env` ou credenciais

## Suporte

Se encontrar problemas:
1. Verifique os logs: `heroku logs --tail`
2. Consulte a documentação do Heroku
3. Verifique se todas as configurações estão corretas 