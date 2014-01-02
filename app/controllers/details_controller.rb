class DetailsController < ApplicationController
 
  before_action :set_detail, only:[:show, :edit, :update, :destroy]

  def index
    @details = Detail.all
  end

  def show
  end

  def new
    @detail = Detail.new
  end 

  def create
    @detail = Detail.new(detail_params)
    if @detail.save
      redirect_to details_path
    else
      render 'new'
    end
  end

  def edit
  end 

  def update
    if @detail.update(detail_params)
      redirect_to details_path
    else
      render 'edit'
    end
  end

  def destroy
    @detail.destroy
    redirect_to details_path
  end

  private
    def detail_params
      params[:detail].permit(:record_at, :desc, :sign, :amount, :type_id, :outline_id)
    end

    def set_detail
      @detail = Detail.find(params[:id])
    end

end
