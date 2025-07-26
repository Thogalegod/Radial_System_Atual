class EquipmentTypesController < ApplicationController
  before_action :set_equipment_type, only: [:show, :edit, :update, :destroy]
  before_action :require_login

  def index
    @equipment_types = EquipmentType.active.ordered.with_equipments
  end

  def show
    @equipment_count = @equipment_type.equipments.count
    @feature_count = @equipment_type.equipment_features.count
    @recent_equipments = @equipment_type.equipments.ordered_by_created.limit(5)
  end

  def new
    @equipment_type = EquipmentType.new
  end

  def create
    respond_to do |format|
      format.html do
        @equipment_type = EquipmentType.new(equipment_type_params)
        
        if @equipment_type.save
          redirect_to equipment_types_path, notice: 'Tipo de equipamento criado com sucesso!'
        else
          render :new, status: :unprocessable_entity
        end
      end
      
      format.json do
        begin
          @equipment_type = EquipmentType.new(equipment_type_params)
          
          if @equipment_type.save
            # Processar características
            process_features(@equipment_type, params[:features]) if params[:features]
            
            render json: { success: true, message: 'Tipo de equipamento criado com sucesso!' }
          else
            render json: { success: false, errors: @equipment_type.errors.full_messages }
          end
        rescue => e
          Rails.logger.error "Erro no create JSON: #{e.message}"
          render json: { success: false, errors: ["Erro interno: #{e.message}"] }, status: :internal_server_error
        end
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      format.html do
        if @equipment_type.update(equipment_type_params)
          redirect_to equipment_types_path, notice: 'Tipo de equipamento atualizado com sucesso!'
        else
          render :edit, status: :unprocessable_entity
        end
      end
      
      format.json do
        begin
          if @equipment_type.update(equipment_type_params)
            # Processar características
            process_features(@equipment_type, params[:features]) if params[:features]
            
            render json: { success: true, message: 'Tipo de equipamento atualizado com sucesso!' }
          else
            render json: { success: false, errors: @equipment_type.errors.full_messages }
          end
        rescue => e
          Rails.logger.error "Erro no update JSON: #{e.message}"
          render json: { success: false, errors: ["Erro interno: #{e.message}"] }, status: :internal_server_error
        end
      end
    end
  end

  def destroy
    equipment_count = @equipment_type.equipments.count
    
    if equipment_count > 0
      redirect_to equipment_types_path, alert: "Não é possível excluir. Existem #{equipment_count} equipamento(s) cadastrado(s) para este tipo."
    elsif @equipment_type.destroy
      redirect_to equipment_types_path, notice: 'Tipo de equipamento removido com sucesso!'
    else
      redirect_to equipment_types_path, alert: 'Erro ao remover tipo de equipamento.'
    end
  end

  def equipment_features
    @equipment_type = EquipmentType.find(params[:id])
    features = @equipment_type.equipment_features.ordered.includes(:equipment_feature_options)
    
    render json: features.map do |feature|
      {
        id: feature.id,
        name: feature.name,
        data_type: feature.data_type,
        required: feature.required,
        filterable: feature.filterable,
        searchable: feature.searchable,
        sortable: feature.sortable,
        description: feature.description,
        unit: feature.unit,
        options: feature.equipment_feature_options.active.ordered.map do |option|
          {
            id: option.id,
            value: option.value,
            label: option.label,
            color: option.color
          }
        end
      }
    end
  end

  def edit_modal
    @equipment_type = EquipmentType.find(params[:id])
    features = @equipment_type.equipment_features.ordered.includes(:equipment_feature_options)
    
    render json: {
      id: @equipment_type.id,
      name: @equipment_type.name,
      primary_color: @equipment_type.primary_color,
      features: features.map do |feature|
        {
          id: feature.id,
          name: feature.name,
          data_type: feature.data_type,
          required: feature.required,
          filterable: feature.filterable,
          searchable: feature.searchable,
          sortable: feature.sortable,
          description: feature.description,
          unit: feature.unit,
          options: feature.equipment_feature_options.active.ordered.map do |option|
            {
              id: option.id,
              value: option.value,
              label: option.label,
              color: option.color
            }
          end
        }
      end
    }
  end

  def duplicate
    @equipment_type = EquipmentType.find(params[:id])
    new_type = @equipment_type.dup
    new_type.name = "#{@equipment_type.name} (Cópia)"
    new_type.active = false
    
    if new_type.save
      # Duplicar características
      @equipment_type.equipment_features.each do |feature|
        new_feature = feature.dup
        new_feature.equipment_type = new_type
        new_feature.save
        
        # Duplicar opções
        feature.equipment_feature_options.each do |option|
          new_option = option.dup
          new_option.equipment_feature = new_feature
          new_option.save
        end
      end
      
      render json: { success: true, message: 'Tipo de equipamento duplicado com sucesso!' }
    else
      render json: { success: false, errors: new_type.errors.full_messages }
    end
  end

  def manage
    @equipment_type = EquipmentType.find(params[:id])
    @equipment_features = @equipment_type.equipment_features.ordered.includes(:equipment_feature_options)
  end

  def update_manage
    # Log para arquivo para debug
    File.open('log/debug.log', 'a') do |f|
      f.puts "=== #{Time.now} - UPDATE_MANAGE INICIADO ==="
      f.puts "Params: #{params.inspect}"
    end
    
    @equipment_type = EquipmentType.find(params[:id])
    
    if @equipment_type.update(equipment_type_params)
      # Processar características se enviadas
      if params[:features].present?
        begin
          # Se features já é um array, usar diretamente, senão fazer parse do JSON
          features_data = if params[:features].is_a?(Array)
            params[:features]
          else
            JSON.parse(params[:features])
          end
          
          # Log para arquivo
          File.open('log/debug.log', 'a') do |f|
            f.puts "Features encontradas: #{features_data.length}"
            f.puts "Features: #{features_data.inspect}"
          end
          
          process_features(@equipment_type, features_data)
          
          # Log de sucesso
          File.open('log/debug.log', 'a') do |f|
            f.puts "✅ PROCESSAMENTO CONCLUÍDO COM SUCESSO"
            f.puts "=========================================="
          end
          
        rescue JSON::ParserError => e
          Rails.logger.error "Erro ao processar JSON das características: #{e.message}"
          File.open('log/debug.log', 'a') do |f|
            f.puts "❌ ERRO JSON: #{e.message}"
          end
        rescue => e
          Rails.logger.error "Erro ao processar características: #{e.message}"
          File.open('log/debug.log', 'a') do |f|
            f.puts "❌ ERRO GERAL: #{e.message}"
          end
        end
      else
        File.open('log/debug.log', 'a') do |f|
          f.puts "⚠️ NENHUMA FEATURE ENVIADA"
        end
      end
      
      redirect_to manage_equipment_type_path(@equipment_type), notice: 'Tipo de equipamento atualizado com sucesso!'
    else
      @equipment_features = @equipment_type.equipment_features.ordered.includes(:equipment_feature_options)
      render :manage, status: :unprocessable_entity
    end
  end

  private

  def set_equipment_type
    @equipment_type = EquipmentType.find(params[:id])
  end

  def equipment_type_params
    if params[:equipment_type]
      params.require(:equipment_type).permit(
        :name, :description, :icon_class, :primary_color, 
        :secondary_color, :accent_color, :active, :sort_order
      )
    else
      # Para requisições JSON do modal
      params.permit(:id, :name, :primary_color, :features)
    end
  end

  def process_features(equipment_type, features_data)
    return unless features_data
    
    Rails.logger.info "Iniciando processamento de características: #{features_data.length} características"
    
    # Log para arquivo
    File.open('log/debug.log', 'a') do |f|
      f.puts "🔄 PROCESSANDO #{features_data.length} CARACTERÍSTICAS"
    end
    
    if equipment_type.persisted?
      # Mapear características existentes por ID e nome
      existing_features_by_id = equipment_type.equipment_features.index_by(&:id)
      existing_features_by_name = equipment_type.equipment_features.index_by(&:name)
      
      # IDs das características que devem ser mantidas
      kept_feature_ids = []
      
      features_data.each_with_index do |feature_data, index|
        feature_id = feature_data[:id] || feature_data['id']
        feature_name = feature_data[:name] || feature_data['name']
        data_type = feature_data[:data_type] || feature_data['data_type']
        
        unless feature_name.present? && data_type.present?
          Rails.logger.error "Dados inválidos para característica: name=#{feature_name}, data_type=#{data_type}"
          next
        end
        
        if feature_id && existing_features_by_id[feature_id.to_i]
          # Atualizar característica existente por ID
          feature = existing_features_by_id[feature_id.to_i]
          Rails.logger.info "Atualizando característica existente por ID: #{feature_name}"
          kept_feature_ids << feature.id
          
          feature.update!(
            name: feature_name,
            data_type: data_type,
            required: feature_data[:required] || feature_data['required'] || false,
            filterable: feature_data[:filterable] || feature_data['filterable'] || false,
            searchable: feature_data[:searchable] || feature_data['searchable'] || false,
            sortable: feature_data[:sortable] || feature_data['sortable'] || false,
            description: feature_data[:description] || feature_data['description'],
            unit: feature_data[:unit] || feature_data['unit']
          )
          
          # Processar opções
          process_feature_options(feature, feature_data)
          
        elsif existing_features_by_name[feature_name]
          # Atualizar característica existente por nome (fallback)
          feature = existing_features_by_name[feature_name]
          Rails.logger.info "Atualizando característica existente por nome: #{feature_name}"
          kept_feature_ids << feature.id
          
          feature.update!(
            data_type: data_type,
            required: feature_data[:required] || feature_data['required'] || false,
            filterable: feature_data[:filterable] || feature_data['filterable'] || false,
            searchable: feature_data[:searchable] || feature_data['searchable'] || false,
            sortable: feature_data[:sortable] || feature_data['sortable'] || false,
            description: feature_data[:description] || feature_data['description'],
            unit: feature_data[:unit] || feature_data['unit']
          )
          
          # Processar opções
          process_feature_options(feature, feature_data)
          
        else
          # Criar nova característica
          Rails.logger.info "Criando nova característica: #{feature_name}"
          feature = equipment_type.equipment_features.create!(
            name: feature_name,
            data_type: data_type,
            required: feature_data[:required] || feature_data['required'] || false,
            filterable: feature_data[:filterable] || feature_data['filterable'] || false,
            searchable: feature_data[:searchable] || feature_data['searchable'] || false,
            sortable: feature_data[:sortable] || feature_data['sortable'] || false,
            description: feature_data[:description] || feature_data['description'],
            unit: feature_data[:unit] || feature_data['unit']
          )
          
          kept_feature_ids << feature.id
          
          # Criar opções
          process_feature_options(feature, feature_data)
        end
      end
      
      # Remover características que não estão na lista
      features_to_delete = equipment_type.equipment_features.where.not(id: kept_feature_ids)
      deleted_count = features_to_delete.count
      
      if deleted_count > 0
        features_to_delete.destroy_all
        Rails.logger.info "Características removidas. Mantidas: #{kept_feature_ids.length}"
        
        # Log para arquivo
        File.open('log/debug.log', 'a') do |f|
          f.puts "🗑️ DELETADAS #{deleted_count} CARACTERÍSTICAS"
          f.puts "✅ MANTIDAS #{kept_feature_ids.length} CARACTERÍSTICAS"
        end
      else
        Rails.logger.info "Nenhuma característica removida. Mantidas: #{kept_feature_ids.length}"
        
        # Log para arquivo
        File.open('log/debug.log', 'a') do |f|
          f.puts "✅ NENHUMA CARACTERÍSTICA DELETADA"
          f.puts "✅ MANTIDAS #{kept_feature_ids.length} CARACTERÍSTICAS"
        end
      end
    end
    
    Rails.logger.info "Processamento de características concluído com sucesso"
  end

  def process_feature_options(feature, feature_data)
    options_data = feature_data[:options] || feature_data['options']
    return unless options_data
    
    Rails.logger.info "Processando #{options_data.length} opções para característica: #{feature.name}"
    
    # Mapear opções existentes por ID e valor
    existing_options_by_id = feature.equipment_feature_options.index_by(&:id)
    existing_options_by_value = feature.equipment_feature_options.index_by(&:value)
    
    # IDs das opções que devem ser mantidas
    kept_option_ids = []
    
    options_data.each do |option_data|
      option_id = option_data[:id] || option_data['id']
      option_value = option_data[:value] || option_data['value']
      option_label = option_data[:label] || option_data['label']
      option_color = option_data[:color] || option_data['color'] || '#3b82f6'
      
      if option_id && existing_options_by_id[option_id.to_i]
        # Atualizar opção existente por ID
        option = existing_options_by_id[option_id.to_i]
        Rails.logger.info "Atualizando opção existente por ID: #{option_value}"
        kept_option_ids << option.id
        
        option.update!(
          value: option_value,
          label: option_label,
          color: option_color
        )
      elsif existing_options_by_value[option_value]
        # Atualizar opção existente por valor
        option = existing_options_by_value[option_value]
        Rails.logger.info "Atualizando opção existente por valor: #{option_value}"
        kept_option_ids << option.id
        
        option.update!(
          label: option_label,
          color: option_color
        )
      else
        # Criar nova opção
        Rails.logger.info "Criando nova opção: #{option_value}"
        new_option = feature.equipment_feature_options.create!(
          value: option_value,
          label: option_label,
          color: option_color
        )
        kept_option_ids << new_option.id
      end
    end
    
    # Remover opções que não estão na lista
    feature.equipment_feature_options.where.not(id: kept_option_ids).destroy_all
    Rails.logger.info "Opções removidas. Mantidas: #{kept_option_ids.length}"
  end

  def require_login
    redirect_to login_path, alert: 'Faça login para acessar esta área.' unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
