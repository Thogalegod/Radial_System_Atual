class EnablePostgresqlExtensions < ActiveRecord::Migration[8.0]
  def up
    # Habilitar extensões PostgreSQL necessárias
    enable_extension "plpgsql" unless extension_enabled?("plpgsql")
    
    # Adicionar outras extensões que podem ser úteis
    enable_extension "uuid-ossp" unless extension_enabled?("uuid-ossp")
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")
  end

  def down
    # Desabilitar extensões se necessário
    disable_extension "uuid-ossp" if extension_enabled?("uuid-ossp")
    disable_extension "pg_trgm" if extension_enabled?("pg_trgm")
    # Não desabilitamos plpgsql pois é fundamental
  end
end 