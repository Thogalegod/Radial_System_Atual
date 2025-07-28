# Características de Equipamentos - Explicação

## 📋 Diferença entre Características Básicas e Específicas

### 🏗️ **Características Básicas (Campos Fixos)**

São campos que **TODOS** os equipamentos possuem, independente do tipo:

| Campo | Descrição | Tipo | Obrigatório |
|-------|-----------|------|-------------|
| `serial_number` | Número de série | String | ✅ Sim |
| `equipment_type_id` | Tipo do equipamento | Integer | ✅ Sim |
| `status` | Status (em estoque, vendido, alugado) | String | ✅ Sim |
| `location` | Localização física | String (select) | ❌ Não |
| `acquisition_date` | Data de aquisição | Date | ❌ Não |
| `acquisition_price` | Preço de aquisição | Decimal | ❌ Não |
| `bandeira` | Bandeira (Verde, Amarelo, Vermelho, etc.) | String (select) | ❌ Não |
| `last_maintenance_date` | Data da última manutenção | Date | ❌ Não |
| `notes` | Observações gerais | Text | ❌ Não |

**Opções de Status:**
- 🟢 **Em Estoque** - Disponível para venda
- 🔴 **Vendido** - Já foi vendido
- 🔵 **Alugado** - Em locação

**Opções de Localização:**
- GP123
- GP140
- Escritório
- Eduardo Super Trafo
- Estrada Tronco

**Opções de Bandeira:**
- Verde
- Amarelo
- Vermelho
- Preto
- Azul
- Verde/Amarelo

**Exemplo de uso:**
```ruby
equipment = Equipment.find(1)
puts equipment.serial_number    # "190902-01"
puts equipment.status           # "em_estoque"
puts equipment.status_display   # "Em Estoque"
puts equipment.location         # "GP123"
puts equipment.acquisition_date # "2024-01-15"
puts equipment.formatted_acquisition_price # "R$ 5.000,00"
puts equipment.bandeira         # "Verde"
```

### 🎯 **Características Específicas (Dinâmicas)**

São características que **VARIAM** conforme o tipo de equipamento. Cada tipo pode ter características únicas:

#### **Transformador MT:**
- **Localização** (select): Subestação Central, Poste, etc.
- **Status** (select): Ativo, Inativo, Manutenção, etc.
- **Tipo de Refrigeração** (select): Seco, Óleo, etc.
- **Bandeira** (select): Verde, Amarelo, Vermelho, etc.
- **Observações** (string): Texto livre
- **teste** (string): Campo de teste

#### **teste de tipo 1:**
- **Corrente Nominal** (select): 100A, 200A, 300A, etc.
- **teste** (string): Campo de teste

**Exemplo de uso:**
```ruby
equipment = Equipment.find(1)
feature_values = equipment.feature_values

# Para Transformador MT
puts feature_values["Localização"]&.formatted_value    # "Subestação Central"
puts feature_values["Tipo de Refrigeração"]&.formatted_value  # "Seco"
puts feature_values["Bandeira"]&.formatted_value       # "Verde"

# Para teste de tipo 1
puts feature_values["Corrente Nominal"]&.formatted_value  # "100A"
```

## 🔄 **Como Funciona na Prática**

### **1. Criação de Equipamento:**
```ruby
# Campos básicos (sempre presentes)
equipment = Equipment.new(
  serial_number: "190902-01",
  equipment_type_id: 1,  # Transformador MT
  status: "em_estoque",
  location: "GP123",
  acquisition_date: Date.new(2024, 1, 15),
  acquisition_price: 5000.00,
  bandeira: "Verde"
)

# Características específicas (dependem do tipo)
equipment.set_feature_value("Localização", "subestacao_central")
equipment.set_feature_value("Tipo de Refrigeração", "seco")
equipment.set_feature_value("Bandeira", "verde")
```

### **2. Exibição na Interface:**
- **Campos básicos** aparecem sempre na tabela
- **Características específicas** aparecem como tags coloridas
- Cada tipo de equipamento pode ter características diferentes

### **3. Filtros:**
- **Campos básicos**: Filtros fixos (status, localização, bandeira)
- **Características específicas**: Filtros dinâmicos baseados no tipo

## 🎨 **Visualização na Tabela**

### **Campos Básicos (Colunas Fixas):**
- **Número**: serial_number
- **Tipo**: equipment_type.name
- **Status**: status (com cores e ícones)
- **Localização**: location (com opções predefinidas)
- **Data de Aquisição**: acquisition_date
- **Preço de Aquisição**: acquisition_price (formatado)
- **Bandeira**: bandeira (com cores)

### **Características Específicas (Tags Dinâmicas):**
- Aparecem na coluna "Características"
- Cada característica é uma tag colorida
- Varia conforme o tipo de equipamento

## 💡 **Vantagens desta Arquitetura**

### **Flexibilidade:**
- ✅ Cada tipo pode ter características únicas
- ✅ Fácil adicionar novos tipos e características
- ✅ Não precisa alterar a estrutura da tabela

### **Organização:**
- ✅ Campos básicos sempre presentes
- ✅ Características específicas organizadas por tipo
- ✅ Interface limpa e intuitiva

### **Escalabilidade:**
- ✅ Suporte a muitos tipos de equipamentos
- ✅ Características ilimitadas por tipo
- ✅ Filtros dinâmicos

## 🔧 **Como Adicionar Novos Tipos/Características**

### **1. Criar novo tipo:**
```ruby
EquipmentType.create!(
  name: "Disjuntor",
  active: true,
  sort_order: 3
)
```

### **2. Adicionar características:**
```ruby
# Para o tipo "Disjuntor"
disjuntor_type = EquipmentType.find_by(name: "Disjuntor")

EquipmentFeature.create!(
  equipment_type: disjuntor_type,
  name: "Tensão Nominal",
  data_type: "select",
  required: true,
  filterable: true
)

# Adicionar opções
tensao_feature = EquipmentFeature.find_by(name: "Tensão Nominal")
EquipmentFeatureOption.create!(
  equipment_feature: tensao_feature,
  label: "13.8 kV",
  value: "13.8kv",
  active: true
)
```

## 📊 **Resumo das Mudanças Recentes**

### **Campos Removidos:**
- ❌ `manufacturer` (Fabricante)
- ❌ `model` (Modelo)
- ❌ `next_maintenance_date` (Próxima Manutenção)

### **Campos Renomeados:**
- 🔄 `installation_date` → `acquisition_date` (Data de Instalação → Data de Aquisição)

### **Novos Campos:**
- ✅ `acquisition_price` (Preço de Aquisição) - Decimal
- ✅ `bandeira` (Bandeira) - String com opções predefinidas

### **Campos Modificados:**
- 🔄 `location` - Agora com opções predefinidas (GP123, GP140, etc.)
- 🔄 `status` - Novas opções: Em Estoque, Vendido, Alugado

### **Status Atualizados:**
- 🟢 **Em Estoque** - Disponível para venda (Verde)
- 🔴 **Vendido** - Já foi vendido (Vermelho)
- 🔵 **Alugado** - Em locação (Azul)

## 📊 **Resumo**

| Aspecto | Características Básicas | Características Específicas |
|---------|------------------------|----------------------------|
| **Presença** | Todos os equipamentos | Varia por tipo |
| **Estrutura** | Campos fixos na tabela | Sistema dinâmico |
| **Flexibilidade** | Limitada | Ilimitada |
| **Filtros** | Fixos | Dinâmicos |
| **Interface** | Colunas da tabela | Tags coloridas |

Esta arquitetura permite que o sistema seja **flexível** para diferentes tipos de equipamentos, mantendo a **organização** e **facilidade de uso**! 🚀 