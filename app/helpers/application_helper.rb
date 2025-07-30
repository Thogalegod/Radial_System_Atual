module ApplicationHelper
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
end
