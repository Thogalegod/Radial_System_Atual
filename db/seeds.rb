# Seeds para o Sistema Genérico de Equipamentos Industriais

puts "🌱 Criando tipos de equipamento..."

# Criar tipo Transformador MT
transformer_type = EquipmentType.find_or_create_by(name: 'Transformador MT') do |type|
  type.description = 'Transformadores de média tensão para distribuição de energia'
  type.icon_class = 'fas fa-bolt'
  type.primary_color = '#3B82F6'    # Blue
  type.secondary_color = '#1E40AF'  # Dark Blue
  type.accent_color = '#DBEAFE'     # Light Blue
  type.sort_order = 1
end

puts "✅ Tipo 'Transformador MT' criado"

# Criar características para Transformador MT
puts "🔧 Criando características..."

features_data = [
  {
    name: 'Tensão BT',
    data_type: 'select',
    unit: 'V',
    description: 'Tensão de baixa tensão do transformador',
    required: true,
    color: '#10B981',
    icon_class: 'fas fa-bolt',
    sort_order: 1
  },
  {
    name: 'Potência',
    data_type: 'select',
    unit: 'kVA',
    description: 'Potência nominal do transformador',
    required: true,
    color: '#F59E0B',
    icon_class: 'fas fa-tachometer-alt',
    sort_order: 2
  },
  {
    name: 'Localização',
    data_type: 'select',
    unit: '',
    description: 'Local onde o transformador está instalado',
    required: false,
    color: '#8B5CF6',
    icon_class: 'fas fa-map-marker-alt',
    sort_order: 3
  },
  {
    name: 'Status',
    data_type: 'select',
    unit: '',
    description: 'Status atual do transformador',
    required: true,
    color: '#EF4444',
    icon_class: 'fas fa-info-circle',
    sort_order: 4
  },
  {
    name: 'Tipo de Refrigeração',
    data_type: 'select',
    unit: '',
    description: 'Tipo de sistema de refrigeração',
    required: false,
    color: '#06B6D4',
    icon_class: 'fas fa-snowflake',
    sort_order: 5
  },
  {
    name: 'Bandeira',
    data_type: 'select',
    unit: '',
    description: 'Bandeira de identificação',
    required: false,
    color: '#84CC16',
    icon_class: 'fas fa-flag',
    sort_order: 6
  },
  {
    name: 'Tipo de Instalação',
    data_type: 'select',
    unit: '',
    description: 'Tipo de instalação do transformador',
    required: false,
    color: '#F97316',
    icon_class: 'fas fa-building',
    sort_order: 7
  },
  {
    name: 'Observações',
    data_type: 'string',
    unit: '',
    description: 'Observações adicionais sobre o equipamento',
    required: false,
    color: '#6B7280',
    icon_class: 'fas fa-sticky-note',
    sort_order: 8
  }
]

features_data.each do |feature_data|
  feature = transformer_type.equipment_features.find_or_create_by(name: feature_data[:name]) do |f|
    f.data_type = feature_data[:data_type]
    f.unit = feature_data[:unit]
    f.description = feature_data[:description]
    f.required = feature_data[:required]
    f.color = feature_data[:color]
    f.icon_class = feature_data[:icon_class]
    f.sort_order = feature_data[:sort_order]
  end
  puts "  ✅ Característica '#{feature.name}' criada"
end

puts "🎨 Criando opções para características..."

# Opções para Tensão BT
bt_feature = transformer_type.equipment_features.find_by(name: 'Tensão BT')
bt_options = [
  { value: '220', label: '220 V', color: '#10B981' },
  { value: '380', label: '380 V', color: '#10B981' },
  { value: '440', label: '440 V', color: '#10B981' },
  { value: '480', label: '480 V', color: '#10B981' }
]

bt_options.each_with_index do |option_data, index|
  bt_feature.equipment_feature_options.create!(
    value: option_data[:value],
    label: option_data[:label],
    color: option_data[:color],
    sort_order: index
  )
end
puts "  ✅ Opções para 'Tensão BT' criadas"

# Opções para Potência
power_feature = transformer_type.equipment_features.find_by(name: 'Potência')
power_options = [
  { value: '30', label: '30 kVA', color: '#F59E0B' },
  { value: '45', label: '45 kVA', color: '#F59E0B' },
  { value: '75', label: '75 kVA', color: '#F59E0B' },
  { value: '112.5', label: '112.5 kVA', color: '#F59E0B' },
  { value: '150', label: '150 kVA', color: '#F59E0B' },
  { value: '225', label: '225 kVA', color: '#F59E0B' },
  { value: '300', label: '300 kVA', color: '#F59E0B' },
  { value: '400', label: '400 kVA', color: '#F59E0B' },
  { value: '500', label: '500 kVA', color: '#F59E0B' },
  { value: '630', label: '630 kVA', color: '#F59E0B' },
  { value: '750', label: '750 kVA', color: '#F59E0B' },
  { value: '1000', label: '1000 kVA', color: '#F59E0B' }
]

power_options.each_with_index do |option_data, index|
  power_feature.equipment_feature_options.create!(
    value: option_data[:value],
    label: option_data[:label],
    color: option_data[:color],
    sort_order: index
  )
end
puts "  ✅ Opções para 'Potência' criadas"

# Opções para Localização
location_feature = transformer_type.equipment_features.find_by(name: 'Localização')
location_options = [
  { value: 'subestacao_central', label: 'Subestação Central', color: '#8B5CF6' },
  { value: 'subestacao_norte', label: 'Subestação Norte', color: '#8B5CF6' },
  { value: 'subestacao_sul', label: 'Subestação Sul', color: '#8B5CF6' },
  { value: 'subestacao_leste', label: 'Subestação Leste', color: '#8B5CF6' },
  { value: 'subestacao_oeste', label: 'Subestação Oeste', color: '#8B5CF6' },
  { value: 'posto_transformacao', label: 'Posto de Transformação', color: '#8B5CF6' },
  { value: 'area_industrial', label: 'Área Industrial', color: '#8B5CF6' },
  { value: 'area_comercial', label: 'Área Comercial', color: '#8B5CF6' },
  { value: 'area_residencial', label: 'Área Residencial', color: '#8B5CF6' }
]

location_options.each_with_index do |option_data, index|
  location_feature.equipment_feature_options.create!(
    value: option_data[:value],
    label: option_data[:label],
    color: option_data[:color],
    sort_order: index
  )
end
puts "  ✅ Opções para 'Localização' criadas"

# Opções para Status
status_feature = transformer_type.equipment_features.find_by(name: 'Status')
status_options = [
  { value: 'ativo', label: 'Ativo', color: '#10B981' },
  { value: 'inativo', label: 'Inativo', color: '#6B7280' },
  { value: 'manutencao', label: 'Em Manutenção', color: '#F59E0B' },
  { value: 'emergencia', label: 'Emergência', color: '#EF4444' },
  { value: 'desligado', label: 'Desligado', color: '#DC2626' }
]

status_options.each_with_index do |option_data, index|
  status_feature.equipment_feature_options.create!(
    value: option_data[:value],
    label: option_data[:label],
    color: option_data[:color],
    sort_order: index
  )
end
puts "  ✅ Opções para 'Status' criadas"

# Opções para Tipo de Refrigeração
cooling_feature = transformer_type.equipment_features.find_by(name: 'Tipo de Refrigeração')
cooling_options = [
  { value: 'seco', label: 'Seco', color: '#06B6D4' },
  { value: 'oleo', label: 'Óleo', color: '#06B6D4' },
  { value: 'resfriado_ar', label: 'Resfriado a Ar', color: '#06B6D4' },
  { value: 'resfriado_agua', label: 'Resfriado a Água', color: '#06B6D4' },
  { value: 'resfriado_oleo', label: 'Resfriado a Óleo', color: '#06B6D4' }
]

cooling_options.each_with_index do |option_data, index|
  cooling_feature.equipment_feature_options.create!(
    value: option_data[:value],
    label: option_data[:label],
    color: option_data[:color],
    sort_order: index
  )
end
puts "  ✅ Opções para 'Tipo de Refrigeração' criadas"

# Opções para Bandeira
flag_feature = transformer_type.equipment_features.find_by(name: 'Bandeira')
flag_options = [
  { value: 'verde', label: 'Verde', color: '#10B981' },
  { value: 'amarela', label: 'Amarela', color: '#F59E0B' },
  { value: 'vermelha', label: 'Vermelha', color: '#EF4444' },
  { value: 'azul', label: 'Azul', color: '#3B82F6' },
  { value: 'laranja', label: 'Laranja', color: '#F97316' },
  { value: 'roxa', label: 'Roxa', color: '#8B5CF6' }
]

flag_options.each_with_index do |option_data, index|
  flag_feature.equipment_feature_options.create!(
    value: option_data[:value],
    label: option_data[:label],
    color: option_data[:color],
    sort_order: index
  )
end
puts "  ✅ Opções para 'Bandeira' criadas"

# Opções para Tipo de Instalação
installation_feature = transformer_type.equipment_features.find_by(name: 'Tipo de Instalação')
installation_options = [
  { value: 'poste', label: 'Poste', color: '#F97316' },
  { value: 'cabine', label: 'Cabine', color: '#F97316' },
  { value: 'subterraneo', label: 'Subterrâneo', color: '#F97316' },
  { value: 'aereo', label: 'Aéreo', color: '#F97316' },
  { value: 'indoor', label: 'Indoor', color: '#F97316' },
  { value: 'outdoor', label: 'Outdoor', color: '#F97316' }
]

installation_options.each_with_index do |option_data, index|
  installation_feature.equipment_feature_options.create!(
    value: option_data[:value],
    label: option_data[:label],
    color: option_data[:color],
    sort_order: index
  )
end
puts "  ✅ Opções para 'Tipo de Instalação' criadas"

# puts "🎯 Criando equipamentos de exemplo..."

# # Criar alguns transformadores de exemplo
# sample_transformers = [
#   {
#     serial_number: 'TMT-001',
#     status: 'active',
#     location: 'subestacao_central',
#     manufacturer: 'WEG',
#     model: 'TMT-500-13.8/0.44',
#     installation_date: Date.current - 2.years,
#     notes: 'Transformador principal da subestação central'
#   },
#   {
#     serial_number: 'TMT-002',
#     status: 'active',
#     location: 'subestacao_norte',
#     manufacturer: 'Siemens',
#     model: 'TMT-300-13.8/0.38',
#     installation_date: Date.current - 1.year,
#     notes: 'Transformador de backup'
#   },
#   {
#     serial_number: 'TMT-003',
#     status: 'manutencao',
#     location: 'area_industrial',
#     manufacturer: 'Schneider',
#     model: 'TMT-750-13.8/0.44',
#     installation_date: Date.current - 3.years,
#     notes: 'Em manutenção preventiva'
#   }
# ]

# sample_transformers.each do |transformer_data|
#   equipment = transformer_type.equipments.create!(transformer_data)
  
#   # Definir valores para características obrigatórias
#   equipment.set_feature_value('Tensão BT', '380')
#   equipment.set_feature_value('Potência', '500')
#   equipment.set_feature_value('Status', 'ativo')
  
#   # Definir valores para características opcionais
#   equipment.set_feature_value('Localização', transformer_data[:location])
#   equipment.set_feature_value('Tipo de Refrigeração', 'oleo')
#   equipment.set_feature_value('Bandeira', 'verde')
#   equipment.set_feature_value('Tipo de Instalação', 'cabine')
  
#   puts "  ✅ Transformador '#{equipment.serial_number}' criado"
# end

puts "🎉 Seeds concluídos com sucesso!"
puts "📊 Resumo:"
puts "  - 1 tipo de equipamento criado"
puts "  - #{transformer_type.equipment_features.count} características criadas"
puts "  - #{transformer_type.equipment_feature_options.count} opções criadas"
puts "  - 0 equipamentos de exemplo criados (comentados temporariamente)" 