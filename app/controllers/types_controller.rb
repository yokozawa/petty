class TypesController < ApplicationController

  before_action :set_type, only:[:edit, :update, :destroy]
  before_filter :authenticate_user!

  def index
    @types = current_user.types.all
  end

  def new
    @type = Type.new
  end

  def create
    @type = Type.new(type_params)
    @type.user_id = current_user.id
    if @type.save
      redirect_to types_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @type.update(type_params)
      redirect_to types_path
    else
      render 'edit'
    end
  end

  def destroy
    @type.destroy
    redirect_to types_path
  end

  private
    def type_params
      params[:type].permit(:label)
    end

    def set_type
      @type = Type.find(params[:id])
    end

end
