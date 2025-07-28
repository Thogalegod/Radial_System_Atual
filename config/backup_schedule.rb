# Script de Backup Automático do Banco de Dados
# Este script deve ser executado via cron job

require 'fileutils'
require 'yaml'

class DatabaseBackup
  def initialize
    @backup_dir = Rails.root.join('backups')
    @max_backups = 10 # Manter apenas os últimos 10 backups
  end

  def perform
    create_backup_directory
    create_backup
    cleanup_old_backups
    log_backup
  end

  private

  def create_backup_directory
    FileUtils.mkdir_p(@backup_dir) unless Dir.exist?(@backup_dir)
  end

  def create_backup
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    backup_file = @backup_dir.join("backup_#{timestamp}.sql")
    
    # Configuração do banco de dados
    db_config = Rails.configuration.database_configuration[Rails.env]
    
    case db_config['adapter']
    when 'postgresql'
      create_postgresql_backup(backup_file, db_config)
    when 'sqlite3'
      create_sqlite_backup(backup_file, db_config)
    else
      puts "Adapter de banco não suportado: #{db_config['adapter']}"
    end
  end

  def create_postgresql_backup(backup_file, db_config)
    host = db_config['host'] || 'localhost'
    port = db_config['port'] || 5432
    database = db_config['database']
    username = db_config['username']
    password = db_config['password']

    # Comando pg_dump
    command = "PGPASSWORD=#{password} pg_dump -h #{host} -p #{port} -U #{username} -d #{database} > #{backup_file}"
    
    system(command)
    
    if $?.success?
      puts "Backup PostgreSQL criado: #{backup_file}"
    else
      puts "Erro ao criar backup PostgreSQL"
    end
  end

  def create_sqlite_backup(backup_file, db_config)
    database_path = db_config['database']
    
    # Para SQLite, apenas copiar o arquivo
    FileUtils.cp(database_path, backup_file)
    puts "Backup SQLite criado: #{backup_file}"
  end

  def cleanup_old_backups
    backup_files = Dir.glob(@backup_dir.join('backup_*.sql')).sort_by { |f| File.mtime(f) }
    
    if backup_files.length > @max_backups
      files_to_delete = backup_files[0...-@max_backups]
      files_to_delete.each do |file|
        File.delete(file)
        puts "Backup antigo removido: #{file}"
      end
    end
  end

  def log_backup
    log_file = @backup_dir.join('backup.log')
    timestamp = Time.current.strftime('%Y-%m-%d %H:%M:%S')
    log_entry = "[#{timestamp}] Backup automático executado com sucesso\n"
    
    File.open(log_file, 'a') do |f|
      f.write(log_entry)
    end
  end
end

# Executar backup se chamado diretamente
if __FILE__ == $0
  backup = DatabaseBackup.new
  backup.perform
end 