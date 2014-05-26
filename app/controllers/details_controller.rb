class DetailsController < ApplicationController

  before_action :set_detail, only:[:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  def index
    @details = current_user.details.order('record_at asc').page params[:page]
  end

  def show
  end

  def new
    @detail = Detail.new
  end

  def create
    detail = current_user.details.build(detail_params)
    if detail.save
      redirect_to :controller => 'summary'
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @detail.update(detail_params)
      redirect_to :controller => 'summary'
    else
      render 'edit'
    end
  end

  def destroy
    @detail.destroy
    redirect_to :controller => 'summary'
  end

  private
  def detail_params
    params[:detail].permit(:user_id, :record_at, :desc, :sign, :amount, :type_id, :outline_id)
  end

  def set_detail
    @detail = Detail.find(params[:id])
  end

end
