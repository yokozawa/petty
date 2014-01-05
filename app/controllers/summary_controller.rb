class SummaryController < ApplicationController

  before_filter :authenticate_user!

  def index
    @types = Type.all;

    @income_cash = Detail.get_current_income(current_user.id).first.amount
    @outgo_cash = Detail.get_current_outgo(current_user.id).first.amount

    @income_sum = 0
    @types.each do |type|
      name = sprintf("@recs_%d_%d", type.id, INCOME)
      @recs = Detail.get_records_by_filter(type.id, INCOME)
      eval("#{name} = @recs")
      @recs.each do |rec|
        @income_sum += rec['amount'] ? rec['amount'] : 0 
      end

      name = sprintf("@recs_%d_%d", type.id, OUTGO)
      @recs = Detail.get_records_by_filter(type.id, OUTGO)
      eval("#{name} = @recs")
      sum = 0
      @recs.each do |rec|
        sum += rec['amount'] ? rec['amount'] : 0
      end
      sum_name = sprintf("@outgo_sum_%d", type.id)
      eval("#{sum_name} = sum")
    end
  end
end
