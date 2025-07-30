WickedPdf.configure do |config|
  config.layout = "pdf"
  config.orientation = "Portrait"
  config.page_size = "A4"
  config.margin = {
    top: 10,
    bottom: 10,
    left: 10,
    right: 10
  }
  config.enable_local_file_access = true
  config.lowquality = false
  config.zoom = 1
  config.dpi = 300
  config.image_quality = 100
  config.disable_smart_shrinking = true
end 