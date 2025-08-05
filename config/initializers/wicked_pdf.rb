WickedPdf.configure do |config|
  config.layout = "pdf"
  config.orientation = "Portrait"
  config.page_size = "A4"
  config.margin = {
    top: 5,
    bottom: 5,
    left: 5,
    right: 5
  }
  config.enable_local_file_access = true
  config.lowquality = false
  config.zoom = 1
  config.dpi = 300
  config.image_quality = 100
  config.disable_smart_shrinking = true
  config.print_media_type = true
  config.page_height = "297mm"
  config.page_width = "210mm"
  config.encoding = "UTF-8"
end 