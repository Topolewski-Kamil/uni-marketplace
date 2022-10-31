if Rails.env.development?
    images = ActiveStorage::Blob.all
    images.each do |image|
    image.delete
    end
end