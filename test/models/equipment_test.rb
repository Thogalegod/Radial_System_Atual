require "test_helper"

class EquipmentTest < ActiveSupport::TestCase
  def setup
    @equipment_type = EquipmentType.create!(name: "Transformador MT")
    @equipment = Equipment.new(
      serial_number: "EQ001",
      equipment_type: @equipment_type,
      status: "active",
      location: "Subestação Central",
      manufacturer: "Siemens",
      model: "T-1000"
    )
  end

  test "should be valid with valid attributes" do
    assert @equipment.valid?
  end

  test "serial_number should be present" do
    @equipment.serial_number = nil
    assert_not @equipment.valid?
    assert_includes @equipment.errors[:serial_number], "não pode ficar em branco"
  end

  test "serial_number should be unique" do
    @equipment.save!
    duplicate = @equipment.dup
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:serial_number], "já está em uso"
  end

  test "serial_number should have minimum length" do
    @equipment.serial_number = "AB"
    assert_not @equipment.valid?
    assert_includes @equipment.errors[:serial_number], "é muito curto (mínimo: 3 caracteres)"
  end

  test "serial_number should have maximum length" do
    @equipment.serial_number = "A" * 101
    assert_not @equipment.valid?
    assert_includes @equipment.errors[:serial_number], "é muito longo (máximo: 100 caracteres)"
  end

  test "equipment_type should be present" do
    @equipment.equipment_type = nil
    assert_not @equipment.valid?
    assert_includes @equipment.errors[:equipment_type], "deve existir"
  end

  test "status should be valid" do
    @equipment.status = "invalid_status"
    assert_not @equipment.valid?
    assert_includes @equipment.errors[:status], "não é válido"
  end

  test "manufacturer should have maximum length" do
    @equipment.manufacturer = "A" * 101
    assert_not @equipment.valid?
    assert_includes @equipment.errors[:manufacturer], "é muito longo (máximo: 100 caracteres)"
  end

  test "model should have maximum length" do
    @equipment.model = "A" * 101
    assert_not @equipment.valid?
    assert_includes @equipment.errors[:model], "é muito longo (máximo: 100 caracteres)"
  end

  test "location should have maximum length" do
    @equipment.location = "A" * 101
    assert_not @equipment.valid?
    assert_includes @equipment.errors[:location], "é muito longo (máximo: 100 caracteres)"
  end

  test "active scope should return only active equipments" do
    active_equipment = Equipment.create!(
      serial_number: "EQ001",
      equipment_type: @equipment_type,
      status: "active"
    )
    inactive_equipment = Equipment.create!(
      serial_number: "EQ002",
      equipment_type: @equipment_type,
      status: "inactive"
    )
    
    assert_includes Equipment.active, active_equipment
    assert_not_includes Equipment.active, inactive_equipment
  end

  test "by_type scope should filter by equipment type" do
    equipment1 = Equipment.create!(
      serial_number: "EQ001",
      equipment_type: @equipment_type
    )
    other_type = EquipmentType.create!(name: "Other Type")
    equipment2 = Equipment.create!(
      serial_number: "EQ002",
      equipment_type: other_type
    )
    
    filtered = Equipment.by_type(@equipment_type.id)
    assert_includes filtered, equipment1
    assert_not_includes filtered, equipment2
  end

  test "status_display should return correct display name" do
    @equipment.status = "active"
    assert_equal "Ativo", @equipment.status_display
    
    @equipment.status = "maintenance"
    assert_equal "Em Manutenção", @equipment.status_display
    
    @equipment.status = "inactive"
    assert_equal "Inativo", @equipment.status_display
    
    @equipment.status = "retired"
    assert_equal "Aposentado", @equipment.status_display
  end

  test "status_color should return correct color" do
    @equipment.status = "active"
    assert_equal "#10b981", @equipment.status_color
    
    @equipment.status = "maintenance"
    assert_equal "#f59e0b", @equipment.status_color
    
    @equipment.status = "inactive"
    assert_equal "#6b7280", @equipment.status_color
    
    @equipment.status = "retired"
    assert_equal "#ef4444", @equipment.status_color
  end

  test "feature_value should return correct value" do
    @equipment.save!
    feature = @equipment.equipment_type.equipment_features.create!(
      name: "Tensão BT",
      data_type: "string"
    )
    value = @equipment.equipment_values.create!(
      equipment_feature: feature,
      value: "380V"
    )
    
    assert_equal value, @equipment.feature_value("Tensão BT")
  end

  test "set_feature_value should create or update value" do
    @equipment.save!
    feature = @equipment.equipment_type.equipment_features.create!(
      name: "Tensão BT",
      data_type: "string"
    )
    
    @equipment.set_feature_value("Tensão BT", "380V")
    assert_equal "380V", @equipment.feature_value("Tensão BT").value
    
    @equipment.set_feature_value("Tensão BT", "400V")
    assert_equal "400V", @equipment.feature_value("Tensão BT").value
  end

  test "display_name should return serial number" do
    assert_equal "EQ001", @equipment.display_name
  end
end 