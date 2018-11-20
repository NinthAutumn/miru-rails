require "google/cloud/vision"
class MenusController < ApplicationController
  def new
    @menu = Menu.new
    vision = Google::Cloud::Vision.new
    file_url = "app/assets/images/curry.jpg"
    @vis = vision.image(file_url).label
    raise
  end
  def create
    @menu = Menu.new(menu_params)
    @menu.user = current_user
  end

  def menu_params
    params.require(:menu).permit(:photo)
  end
end
