require 'image_processing/mini_magick'

class ImageUploader < Shrine
  include ImageProcessing::MiniMagick
  plugin :pretty_location
  plugin :processing
  plugin :versions
  plugin :determine_mime_type
  plugin :cached_attachment_data
  plugin :remove_attachment
  plugin :store_dimensions
  plugin :delete_raw
  plugin :delete_promoted

  Attacher.validate do
    validate_max_size 5.megabyte, message: 'is too large (max is 5 MB)'
    validate_mime_type_inclusion ['image/jpg', 'image/jpeg', 'image/png']
  end

  process(:store) do |io|
    original = io.download
    pipeline = ImageProcessing::MiniMagick.source(original)

    size_800 = pipeline.resize_to_limit!(800, 800)
    size_400 = pipeline.resize_to_limit!(400, 400)
    size_150 = pipeline.resize_to_fill!(800, 150)

    original.close!

    {original: io, large: size_800, medium: size_400, banner: size_150}
  end
end
