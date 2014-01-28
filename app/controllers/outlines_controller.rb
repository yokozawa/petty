class OutlinesController < ApplicationController

  before_action :set_outline, only:[:edit, :update, :destroy]
  before_filter :authenticate_user!

  def index
    @outlines = current_user.outlines.all
  end

  def new
    @outline = Outline.new
  end

  def create
    outline = current_user.outlines.build(outline_params)
    if outline.save
      redirect_to outlines_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @outline.update(outline_params)
      redirect_to outlines_path
    else
      render 'edit'
    end
  end

  def destroy
    outline.destroy
    redirect_to outlines_path
  end

  private
    def outline_params
      params[:outline].permit(:label)
    end

    def set_outline
      @outline = Outline.find(params[:id])
    end

end
