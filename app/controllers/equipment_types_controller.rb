class EquipmentTypesController < ApplicationController
  before_action :require_login
  before_action :require_resource_permission, :equipment_types, :read, only: [:index, :show, :equipment_features, :edit_modal]
  before_action :require_resource_permission, :equipment_types, :create, only: [:new, :create]
  before_action :require_resource_permission, :equipment_types, :update, only: [:edit, :update, :update_manage]
  before_action :require_resource_permission, :equipment_types, :destroy, only: [:destroy]
  before_action :require_resource_permission, :equipment_types, :manage, only: [:manage, :duplicate]
  before_action :set_equipment_type, only: [:show, :edit, :update, :destroy]

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
        options: feature.equipment_feature_options.map do |option|
          {
            id: option.id,
            value: option.value,
            label: option.label
          }
        end
      }
    end
  end

  def edit_modal
    @equipment_type = EquipmentType.find(params[:id])
    features = @equipment_type.equipment_features.ordered.includes(:equipment_feature_options)
    
    render json: {
      equipment_type: {
        id: @equipment_type.id,
        name: @equipment_type.name,
        description: @equipment_type.description,
        active: @equipment_type.active
      },
      features: features.map do |feature|
        {
          id: feature.id,
          name: feature.name,
          data_type: feature.data_type,
          required: feature.required,
          options: feature.equipment_feature_options.map do |option|
            {
              id: option.id,
              value: option.value,
              label: option.label
            }
          end
        }
      end
    }
  end

  def duplicate
    @equipment_type = EquipmentType.find(params[:id])
    
    # Criar cópia do tipo de equipamento
    new_equipment_type = @equipment_type.dup
    new_equipment_type.name = "#{@equipment_type.name} (Cópia)"
    new_equipment_type.active = false
    
    if new_equipment_type.save
      # Duplicar características
      @equipment_type.equipment_features.each do |feature|
        new_feature = feature.dup
        new_feature.equipment_type = new_equipment_type
        
        if new_feature.save
          # Duplicar opções
          feature.equipment_feature_options.each do |option|
            new_option = option.dup
            new_option.equipment_feature = new_feature
            new_option.save
          end
        end
      end
      
      redirect_to equipment_types_path, notice: 'Tipo de equipamento duplicado com sucesso!'
    else
      redirect_to equipment_types_path, alert: 'Erro ao duplicar tipo de equipamento.'
    end
  end

  def manage
    @equipment_type = EquipmentType.find(params[:id])
  end

  def update_manage
    # Log para arquivo para debug
    File.open('log/debug.log', 'a') do |f|
      f.puts "=== UPDATE MANAGE DEBUG ==="
      f.puts "Time: #{Time.current}"
      f.puts "Params: #{params.inspect}"
      f.puts "Equipment Type ID: #{params[:id]}"
      f.puts "Features: #{params[:features].inspect}" if params[:features]
      f.puts "=========================="
    end
    
    @equipment_type = EquipmentType.find(params[:id])
    
    respond_to do |format|
      format.html do
        if @equipment_type.update(equipment_type_params)
          # Processar características
          process_features(@equipment_type, params[:features]) if params[:features]
          
          redirect_to manage_equipment_type_path(@equipment_type), notice: 'Tipo de equipamento atualizado com sucesso!'
        else
          render :manage, status: :unprocessable_entity
        end
      end
      
      format.json do
        begin
          if @equipment_type.update(equipment_type_params)
            # Processar características
            process_features(@equipment_type, params[:features]) if params[:features]
            
            render json: { 
              success: true, 
              message: 'Tipo de equipamento atualizado com sucesso!',
              equipment_type: {
                id: @equipment_type.id,
                name: @equipment_type.name,
                description: @equipment_type.description,
                active: @equipment_type.active
              }
            }
          else
            render json: { success: false, errors: @equipment_type.errors.full_messages }
          end
        rescue => e
          Rails.logger.error "Erro no update_manage JSON: #{e.message}"
          render json: { success: false, errors: ["Erro interno: #{e.message}"] }, status: :internal_server_error
        end
      end
    end
  end

  private

  def set_equipment_type
    @equipment_type = EquipmentType.find(params[:id])
  end

  def equipment_type_params
    if params[:equipment_type]
      params.require(:equipment_type).permit(:name, :description, :active)
    else
      {}
    end
  end

  def process_features(equipment_type, features_data)
    return unless features_data
    
    # Limpar características existentes se necessário
    if params[:clear_existing_features] == 'true'
      equipment_type.equipment_features.destroy_all
    end
    
    features_data.each do |feature_data|
      feature_name = feature_data[:name] || feature_data['name']
      data_type = feature_data[:data_type] || feature_data['data_type'] || 'text'
      required = feature_data[:required] || feature_data['required'] || false
      
      # Criar ou atualizar característica
      feature = equipment_type.equipment_features.find_or_initialize_by(name: feature_name)
      feature.data_type = data_type
      feature.required = required
      
      if feature.save
        # Processar opções se for do tipo select
        if data_type == 'select' && (feature_data[:options] || feature_data['options'])
          process_feature_options(feature, feature_data)
        end
      end
    end
  end

  def process_feature_options(feature, feature_data)
    options_data = feature_data[:options] || feature_data['options']
    return unless options_data
    
    # Limpar opções existentes
    feature.equipment_feature_options.destroy_all
    
    options_data.each do |option_data|
      value = option_data[:value] || option_data['value']
      label = option_data[:label] || option_data['label'] || value
      
      feature.equipment_feature_options.create!(
        value: value,
        label: label
      )
    end
  end
end
