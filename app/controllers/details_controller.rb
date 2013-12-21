class DetailsController < ApplicationController
  def index
    @details = Details.all
  end
end
