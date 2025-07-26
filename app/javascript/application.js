// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Rails UJS para suporte a method: :delete
import Rails from "@rails/ujs"
Rails.start()

// Configuração para confirmações de exclusão
document.addEventListener('DOMContentLoaded', function() {
  // Interceptar cliques em links com data-confirm
  document.addEventListener('click', function(e) {
    if (e.target.closest('a[data-confirm]')) {
      const link = e.target.closest('a[data-confirm]')
      const message = link.getAttribute('data-confirm')
      
      if (!confirm(message)) {
        e.preventDefault()
        return false
      }
    }
  })
}) 