module ApplicationHelper
  # Formatação de valores monetários
  def format_currency(value)
    return "R$ 0,00" if value.nil? || value.zero?
    "R$ #{value.to_f.round(2).to_s.gsub('.', ',')}"
  end

  def format_percentage(value)
    return "0%" if value.nil? || value.zero?
    "#{(value * 100).round(2)}%"
  end

  def valor_por_extenso(valor)
    return "zero reais" if valor == 0
    
    # Separa reais e centavos
    reais = valor.to_i
    centavos = ((valor - reais) * 100).round
    
    # Arrays para conversão
    unidades = ['', 'um', 'dois', 'três', 'quatro', 'cinco', 'seis', 'sete', 'oito', 'nove']
    dezenas = ['', '', 'vinte', 'trinta', 'quarenta', 'cinquenta', 'sessenta', 'setenta', 'oitenta', 'noventa']
    especiais = ['dez', 'onze', 'doze', 'treze', 'quatorze', 'quinze', 'dezesseis', 'dezessete', 'dezoito', 'dezenove']
    
    def converter_centenas(num)
      return "" if num == 0
      
      if num < 10
        unidades[num]
      elsif num < 20
        especiais[num - 10]
      elsif num < 100
        if num % 10 == 0
          dezenas[num / 10]
        else
          "#{dezenas[num / 10]} e #{unidades[num % 10]}"
        end
      elsif num < 1000
        if num == 100
          "cem"
        elsif num < 200
          "cento e #{converter_centenas(num % 100)}"
        else
          "#{unidades[num / 100]}centos#{num % 100 > 0 ? ' e ' + converter_centenas(num % 100) : ''}"
        end
      else
        milhares = num / 1000
        resto = num % 1000
        
        if milhares == 1
          "mil#{resto > 0 ? ' e ' + converter_centenas(resto) : ''}"
        else
          "#{converter_centenas(milhares)} mil#{resto > 0 ? ' e ' + converter_centenas(resto) : ''}"
        end
      end
    end
    
    # Converte reais
    texto_reais = converter_centenas(reais)
    texto_reais = "zero" if texto_reais.empty?
    
    # Converte centavos
    if centavos > 0
      texto_centavos = converter_centenas(centavos)
      "#{texto_reais} reais e #{texto_centavos} centavos"
    else
      "#{texto_reais} reais"
    end
  end

  # Formatação de datas
  def format_date(date)
    return "-" if date.nil?
    date.strftime("%d/%m/%Y")
  end

  def format_datetime(datetime)
    return "-" if datetime.nil?
    datetime.strftime("%d/%m/%Y %H:%M")
  end

  def format_time(time)
    return "-" if time.nil?
    time.strftime("%H:%M")
  end

  # Formatação de documentos
  def format_document(document_number, document_type)
    return "-" if document_number.blank?
    
    case document_type
    when 'CNPJ'
      format_cnpj(document_number)
    when 'CPF'
      format_cpf(document_number)
    else
      document_number
    end
  end

  def format_cnpj(cnpj)
    return cnpj if cnpj.blank?
    cnpj.gsub(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '\1.\2.\3/\4-\5')
  end

  def format_cpf(cpf)
    return cpf if cpf.blank?
    cpf.gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4')
  end

  # Formatação de telefone
  def format_phone(phone)
    return "-" if phone.blank?
    phone.gsub(/(\d{2})(\d{4,5})(\d{4})/, '(\1) \2-\3')
  end

  # Formatação de CEP
  def format_zip_code(zip_code)
    return "-" if zip_code.blank?
    zip_code.gsub(/(\d{5})(\d{3})/, '\1-\2')
  end

  # Helpers de status
  def status_badge_class(status)
    case status.to_s.downcase
    when 'ativo', 'em_estoque', 'ativo'
      'badge-success'
    when 'concluido', 'vendido'
      'badge-secondary'
    when 'alugado'
      'badge-primary'
    when 'pendente'
      'badge-warning'
    when 'cancelado'
      'badge-danger'
    else
      'badge-light'
    end
  end

  def status_icon(status)
    case status.to_s.downcase
    when 'ativo', 'em_estoque'
      'fas fa-check-circle'
    when 'concluido'
      'fas fa-check-double'
    when 'alugado'
      'fas fa-handshake'
    when 'pendente'
      'fas fa-clock'
    when 'cancelado'
      'fas fa-times-circle'
    else
      'fas fa-question-circle'
    end
  end

  # Helpers de validação
  def valid_email?(email)
    email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)
  end

  def valid_phone?(phone)
    phone.present? && phone.match?(/\A\(\d{2}\)\s\d{4,5}-\d{4}\z/)
  end

  def valid_zip_code?(zip_code)
    zip_code.present? && zip_code.match?(/\A\d{5}-?\d{3}\z/)
  end

  # Helpers de navegação
  def active_class(path)
    current_page?(path) ? 'active' : ''
  end

  def nav_link_class(path)
    "nav-link #{active_class(path)}"
  end

  # Helpers de tempo
  def time_ago_in_words_pt(date)
    return "-" if date.nil?
    
    distance = Time.current - date
    case distance
    when 0..1.minute
      "agora mesmo"
    when 1.minute..1.hour
      "#{distance.to_i / 1.minute} minutos atrás"
    when 1.hour..1.day
      "#{distance.to_i / 1.hour} horas atrás"
    when 1.day..1.week
      "#{distance.to_i / 1.day} dias atrás"
    when 1.week..1.month
      "#{distance.to_i / 1.week} semanas atrás"
    when 1.month..1.year
      "#{distance.to_i / 1.month} meses atrás"
    else
      "#{distance.to_i / 1.year} anos atrás"
    end
  end

  # Helpers de formatação de texto
  def truncate_text(text, length = 50)
    return "-" if text.blank?
    text.length > length ? "#{text[0...length]}..." : text
  end

  def highlight_search(text, query)
    return text if query.blank?
    text.gsub(/(#{Regexp.escape(query)})/i, '<mark>\1</mark>').html_safe
  end

  # Helpers de números
  def number_with_delimiter(number)
    return "0" if number.nil?
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
  end

  def format_file_size(bytes)
    return "0 B" if bytes.nil? || bytes.zero?
    
    units = %w[B KB MB GB TB]
    exp = (Math.log(bytes) / Math.log(1024)).to_i
    exp = [exp, units.length - 1].min
    
    "%.1f %s" % [bytes.to_f / (1024 ** exp), units[exp]]
  end

  # Helpers de segurança
  def sanitize_html(html)
    return "" if html.blank?
    ActionController::Base.helpers.sanitize(html, tags: %w[p br strong em u])
  end

  # Helpers de cache
  def cache_key_for_collection(collection, prefix = nil)
    key = "#{collection.model.name.downcase}/#{collection.maximum(:updated_at)&.to_i}"
    key = "#{prefix}/#{key}" if prefix
    key
  end

  def role_display_name(role)
    case role
    when 'admin'
      'Administrador'
    when 'manager'
      'Gerente'
    when 'operator'
      'Operador'
    when 'viewer'
      'Visualizador'
    else
      role.titleize
    end
  end

  def role_badge_color(role)
    case role
    when 'admin'
      'danger'
    when 'manager'
      'warning'
    when 'operator'
      'info'
    when 'viewer'
      'secondary'
    else
      'light'
    end
  end

  def can_access_menu?(resource, action = nil)
    current_user&.can_access?(resource, action) || false
  end

  def show_menu_item?(resource, action = nil)
    can_access_menu?(resource, action)
  end

  def current_user_role_display
    role_display_name(current_user&.role)
  end
end
