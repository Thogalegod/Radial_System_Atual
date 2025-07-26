require "test_helper"

class EquipmentTypeTest < ActiveSupport::TestCase
  def setup
    @equipment_type = EquipmentType.new(
      name: "Transformador MT",
      description: "Transformadores de média tensão",
      icon_class: "fas fa-bolt",
      primary_color: "#3B82F6",
      secondary_color: "#1E40AF",
      accent_color: "#DBEAFE"
    )
  end

  test "should be valid with valid attributes" do
    assert @equipment_type.valid?
  end

  test "name should be present" do
    @equipment_type.name = nil
    assert_not @equipment_type.valid?
    assert_includes @equipment_type.errors[:name], "não pode ficar em branco"
  end

  test "name should be unique" do
    @equipment_type.save!
    duplicate = @equipment_type.dup
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "já está em uso"
  end

  test "name should have minimum length" do
    @equipment_type.name = "A"
    assert_not @equipment_type.valid?
    assert_includes @equipment_type.errors[:name], "é muito curto (mínimo: 2 caracteres)"
  end

  test "name should have maximum length" do
    @equipment_type.name = "A" * 101
    assert_not @equipment_type.valid?
    assert_includes @equipment_type.errors[:name], "é muito longo (máximo: 100 caracteres)"
  end

  test "primary_color should be valid hex color" do
    @equipment_type.primary_color = "invalid"
    assert_not @equipment_type.valid?
    assert_includes @equipment_type.errors[:primary_color], "formato inválido"
  end

  test "should set default colors if not provided" do
    equipment_type = EquipmentType.new(name: "Test Type")
    equipment_type.valid?
    assert_equal "#3B82F6", equipment_type.primary_color
    assert_equal "#1E40AF", equipment_type.secondary_color
    assert_equal "#DBEAFE", equipment_type.accent_color
  end

  test "should set default icon if not provided" do
    equipment_type = EquipmentType.new(name: "Test Type")
    equipment_type.valid?
    assert_equal "fas fa-cog", equipment_type.icon_class
  end

  test "active scope should return only active types" do
    active_type = EquipmentType.create!(name: "Active Type", active: true)
    inactive_type = EquipmentType.create!(name: "Inactive Type", active: false)
    
    assert_includes EquipmentType.active, active_type
    assert_not_includes EquipmentType.active, inactive_type
  end

  test "ordered scope should return types in sort order" do
    type1 = EquipmentType.create!(name: "Type 1", sort_order: 2)
    type2 = EquipmentType.create!(name: "Type 2", sort_order: 1)
    
    ordered_types = EquipmentType.ordered
    assert_equal type2, ordered_types.first
    assert_equal type1, ordered_types.last
  end

  test "equipment_count should return correct count" do
    equipment_type = EquipmentType.create!(name: "Test Type")
    equipment_type.equipments.create!(serial_number: "EQ001")
    equipment_type.equipments.create!(serial_number: "EQ002")
    
    assert_equal 2, equipment_type.equipment_count
  end

  test "feature_count should return correct count" do
    equipment_type = EquipmentType.create!(name: "Test Type")
    equipment_type.equipment_features.create!(name: "Feature 1", data_type: "string")
    equipment_type.equipment_features.create!(name: "Feature 2", data_type: "integer")
    
    assert_equal 2, equipment_type.feature_count
  end

  test "css_style should return valid CSS" do
    equipment_type = EquipmentType.create!(
      name: "Test Type",
      primary_color: "#FF0000",
      secondary_color: "#00FF00",
      accent_color: "#0000FF"
    )
    
    expected_style = "--primary-color: #FF0000; --secondary-color: #00FF00; --accent-color: #0000FF;"
    assert_equal expected_style, equipment_type.css_style
  end

  test "display_name should return name" do
    assert_equal "Transformador MT", @equipment_type.display_name
  end
end 