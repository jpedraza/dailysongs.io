class ManageController < ApplicationController
  layout "manage"

  http_basic_authenticate_with(
    name:     ENV["MANAGE_USERNAME"],
    password: ENV["MANAGE_PASSWORD"],
    if:       -> { Rails.env.production? }
  )
end
