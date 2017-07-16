require 'image_processing/mini_magick'

class ImageUploader < Shrine
  include ImageProcessing::MiniMagick
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

    size_800 = resize_to_limit(original, 800, 800) { |cmd| cmd.auto_orient } # orient rotated images
    size_400 = resize_to_limit(size_800,  400, 400)
    size_150 = resize_to_fill(size_800, 800, 150)

    {original: io, large: size_800, medium: size_400, banner: size_150}
  end
end
