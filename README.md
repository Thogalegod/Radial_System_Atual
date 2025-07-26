# Sistema de Gerenciamento de Equipamentos Industriais

Sistema genérico e escalável para gerenciamento de equipamentos industriais, desenvolvido em Rails 8.

## 🚀 Características Principais

- **Arquitetura Genérica**: Suporte a qualquer tipo de equipamento industrial
- **Características Dinâmicas**: Sistema flexível de características configuráveis
- **Interface Moderna**: Design responsivo e intuitivo
- **Filtros Avançados**: Busca e filtros dinâmicos por características
- **Autenticação**: Sistema de login seguro
- **Exportação**: Suporte a exportação de dados

## 📋 Pré-requisitos

- Ruby 3.4.5+
- Rails 8.0.2+
- PostgreSQL 12+
- Node.js 18+ (para assets)

## 🛠️ Instalação

1. **Clone o repositório**
```bash
git clone <repository-url>
cd Radial_System_Atual
```

2. **Instale as dependências**
```bash
bundle install
```

3. **Configure o banco de dados**
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

4. **Inicie o servidor**
```bash
bin/rails server
```

5. **Acesse a aplicação**
```
http://localhost:3000
```

## 🏗️ Arquitetura do Sistema

### Modelos Principais

#### `EquipmentType` (Tipos de Equipamento)
- Define categorias de equipamentos (ex: Transformador MT, Disjuntor)
- Configura cores e ícones para personalização
- Contém características específicas do tipo

#### `Equipment` (Equipamentos)
- Instâncias individuais de equipamentos
- Possui número de série único
- Referencia um tipo de equipamento
- Armazena dados básicos (localização, fabricante, etc.)

#### `EquipmentFeature` (Características)
- Define características possíveis para cada tipo
- Suporta diferentes tipos de dados (string, integer, select, etc.)
- Configurável para filtros, busca e validações

#### `EquipmentValue` (Valores das Características)
- Armazena valores específicos para cada equipamento
- Sistema EAV (Entity-Attribute-Value) para flexibilidade
- Suporte a cores e formatação

#### `EquipmentFeatureOption` (Opções de Características)
- Opções pré-definidas para características do tipo "select"
- Suporte a cores e ícones
- Ordenação configurável

### Relacionamentos

```
EquipmentType
├── has_many :equipments
├── has_many :equipment_features
└── has_many :equipment_feature_options (through: :equipment_features)

Equipment
├── belongs_to :equipment_type
├── has_many :equipment_values
└── has_many :equipment_features (through: :equipment_type)

EquipmentFeature
├── belongs_to :equipment_type
├── has_many :equipment_values
└── has_many :equipment_feature_options

EquipmentValue
├── belongs_to :equipment
└── belongs_to :equipment_feature

EquipmentFeatureOption
└── belongs_to :equipment_feature
```

## 🔧 Desenvolvimento

### Estrutura de Diretórios

```
app/
├── controllers/
│   ├── equipment_types_controller.rb
│   ├── equipments_controller.rb
│   ├── equipment_features_controller.rb
│   ├── equipment_feature_options_controller.rb
│   └── dashboard_controller.rb
├── models/
│   ├── equipment_type.rb
│   ├── equipment.rb
│   ├── equipment_feature.rb
│   ├── equipment_value.rb
│   └── equipment_feature_option.rb
└── views/
    ├── equipment_types/
    ├── equipments/
    ├── equipment_features/
    ├── equipment_feature_options/
    └── dashboard/
```

### Convenções de Código

#### Controllers
- Use `before_action` para autenticação e setup
- Implemente filtros genéricos em `apply_filters_and_sorting`
- Use strong parameters para segurança

#### Models
- Validações específicas por tipo de dado
- Scopes para consultas comuns
- Métodos de instância para lógica de negócio

#### Views
- Partials para reutilização de código
- CSS customizado por tipo de equipamento
- JavaScript para interatividade

### Testes

Execute os testes com:
```bash
bin/rails test
```

Para testes específicos:
```bash
bin/rails test test/models/equipment_test.rb
bin/rails test test/controllers/equipments_controller_test.rb
```

### Migrations

Para criar novas migrações:
```bash
bin/rails generate migration AddFieldToTable
```

### Seeds

Os dados iniciais estão em `db/seeds.rb`:
- Tipos de equipamento padrão
- Características para "Transformador MT"
- Opções pré-definidas

## 🎨 Personalização

### Cores por Tipo de Equipamento

Cada tipo pode ter cores personalizadas:
```ruby
equipment_type = EquipmentType.create!(
  name: "Transformador MT",
  primary_color: "#3B82F6",
  secondary_color: "#1E40AF",
  accent_color: "#DBEAFE"
)
```

### Características Dinâmicas

Defina características para cada tipo:
```ruby
feature = equipment_type.equipment_features.create!(
  name: "Tensão BT",
  data_type: "string",
  required: true,
  searchable: true,
  filterable: true
)
```

### Opções de Características

Para características do tipo "select":
```ruby
option = feature.equipment_feature_options.create!(
  value: "380V",
  label: "380 Volts",
  color: "#10b981",
  icon_class: "fas fa-bolt"
)
```

## 🔍 Filtros e Busca

### Filtros Básicos
- Número de série
- Tipo de equipamento
- Status
- Localização
- Fabricante
- Data de instalação

### Filtros Dinâmicos
- Características específicas por tipo
- Valores de opções para características "select"
- Busca textual em valores

### Ordenação
- Por qualquer campo básico
- Por características dinâmicas
- Crescente/decrescente

## 📊 Dashboard

O dashboard fornece:
- Estatísticas gerais
- Gráficos por status e tipo
- Equipamentos recentes
- Alertas de manutenção
- Ações rápidas

## 🔐 Autenticação

Sistema de autenticação simples:
- Login por email/senha
- Sessões persistentes
- Proteção de rotas com `before_action :require_login`

## 🚀 Deploy

### Produção
1. Configure variáveis de ambiente
2. Execute migrações
3. Compile assets
4. Configure servidor web (Nginx/Apache)

### Variáveis de Ambiente
```bash
DATABASE_URL=postgresql://user:pass@localhost/dbname
SECRET_KEY_BASE=your-secret-key
RAILS_ENV=production
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT.

## 🆘 Suporte

Para dúvidas ou problemas:
1. Verifique a documentação
2. Execute os testes
3. Abra uma issue no GitHub

## 🔄 Changelog

### v1.0.0
- Sistema genérico de equipamentos
- Características dinâmicas
- Interface moderna
- Filtros avançados
- Autenticação
- Dashboard informativo
