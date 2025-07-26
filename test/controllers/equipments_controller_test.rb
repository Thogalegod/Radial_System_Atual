require "test_helper"

class EquipmentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @equipment_type = EquipmentType.create!(name: "Transformador MT")
    @equipment = Equipment.create!(
      serial_number: "EQ001",
      equipment_type: @equipment_type,
      status: "active",
      location: "Subestação Central"
    )
    
    # Criar usuário para autenticação
    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "should get index" do
    # Simular login
    post login_path, params: { email: @user.email, password: "password123" }
    
    get equipments_url
    assert_response :success
    assert_not_nil assigns(:equipments)
    assert_not_nil assigns(:equipment_types)
  end

  test "should get new" do
    post login_path, params: { email: @user.email, password: "password123" }
    
    get new_equipment_url
    assert_response :success
    assert_not_nil assigns(:equipment)
    assert_not_nil assigns(:equipment_types)
  end

  test "should create equipment" do
    post login_path, params: { email: @user.email, password: "password123" }
    
    assert_difference('Equipment.count') do
      post equipments_url, params: { 
        equipment: { 
          serial_number: "EQ002",
          equipment_type_id: @equipment_type.id,
          status: "active",
          location: "Nova Localização"
        }
      }
    end

    assert_redirected_to equipments_path
    assert_equal "Equipamento cadastrado com sucesso!", flash[:notice]
  end

  test "should show equipment" do
    post login_path, params: { email: @user.email, password: "password123" }
    
    get equipment_url(@equipment)
    assert_response :success
    assert_equal @equipment, assigns(:equipment)
  end

  test "should get edit" do
    post login_path, params: { email: @user.email, password: "password123" }
    
    get edit_equipment_url(@equipment)
    assert_response :success
    assert_equal @equipment, assigns(:equipment)
  end

  test "should update equipment" do
    post login_path, params: { email: @user.email, password: "password123" }
    
    patch equipment_url(@equipment), params: { 
      equipment: { 
        location: "Localização Atualizada",
        status: "maintenance"
      }
    }
    
    assert_redirected_to equipments_path
    assert_equal "Equipamento atualizado com sucesso!", flash[:notice]
    
    @equipment.reload
    assert_equal "Localização Atualizada", @equipment.location
    assert_equal "maintenance", @equipment.status
  end

  test "should destroy equipment" do
    post login_path, params: { email: @user.email, password: "password123" }
    
    assert_difference('Equipment.count', -1) do
      delete equipment_url(@equipment)
    end

    assert_redirected_to equipments_path
    assert_equal "Equipamento EQ001 removido com sucesso!", flash[:notice]
  end

  test "should filter equipments" do
    post login_path, params: { email: @user.email, password: "password123" }
    
    get filter_equipments_url, params: { 
      equipment_type_id: @equipment_type.id,
      status: "active"
    }, xhr: true
    
    assert_response :success
    assert_equal "application/json", response.content_type
    
    json_response = JSON.parse(response.body)
    assert_not_nil json_response["equipments"]
    assert_not_nil json_response["total_count"]
  end

  test "should export csv" do
    post login_path, params: { email: @user.email, password: "password123" }
    
    get export_csv_equipments_url, params: { format: :csv }
    assert_response :success
    assert_equal "text/csv; charset=utf-8", response.content_type
    assert_includes response.headers["Content-Disposition"], "equipamentos_"
  end

  test "should require login for index" do
    get equipments_url
    assert_redirected_to login_path
    assert_equal "Faça login para acessar esta área.", flash[:alert]
  end

  test "should require login for new" do
    get new_equipment_url
    assert_redirected_to login_path
  end

  test "should require login for create" do
    post equipments_url, params: { equipment: { serial_number: "EQ003" } }
    assert_redirected_to login_path
  end

  test "should require login for show" do
    get equipment_url(@equipment)
    assert_redirected_to login_path
  end

  test "should require login for edit" do
    get edit_equipment_url(@equipment)
    assert_redirected_to login_path
  end

  test "should require login for update" do
    patch equipment_url(@equipment), params: { equipment: { location: "Test" } }
    assert_redirected_to login_path
  end

  test "should require login for destroy" do
    delete equipment_url(@equipment)
    assert_redirected_to login_path
  end

  test "should apply filters and sorting" do
    post login_path, params: { email: @user.email, password: "password123" }
    
    # Testar filtro por tipo
    get equipments_url, params: { equipment_type_id: @equipment_type.id }
    assert_response :success
    assert_equal 1, assigns(:equipments).count
    
    # Testar ordenação
    get equipments_url, params: { sort_field: "serial_number", sort_direction: "desc" }
    assert_response :success
    assert_not_nil assigns(:equipments)
  end
end 