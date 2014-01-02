class SummaryController < ApplicationController
  def index
    @types = Type.all;
  end
end
