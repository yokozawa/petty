class SummaryController < ApplicationController

  before_filter :authenticate_user!

  def index
    @types = current_user.types

    @first_day = if params[:y] and params[:m]
      date = sprintf("%04d-%02d", params[:y], params[:m])
      Date.parse(sprintf("%s-01", date))
    else 
      today = Date.today
      date = sprintf("%04d-%02d", today.year, today.month)
      Time.now.beginning_of_month.to_date
    end

    end_day = @first_day.end_of_month.to_date
    @details = current_user.details.find(:all,
      :conditions => 
        {:record_at => @first_day...end_day}, :order => 'record_at asc')

    @income_cash = Detail.get_current_income(current_user.id, date).first.amount
    @outgo_cash = Detail.get_current_outgo(current_user.id, date).first.amount

    @income_sum = 0
    @types.each do |type|
      name = sprintf("@recs_%d_%d", type.id, INCOME)
      @recs = Detail.get_records_by_filter(current_user.id, type.id, INCOME, date)
      instance_variable_set("#{name}", @recs)
      @recs.each do |rec|
        @income_sum += rec['amount'] ? rec['amount'] : 0 
      end

      name = sprintf("@recs_%d_%d", type.id, OUTGO)
      @recs = Detail.get_records_by_filter(current_user.id, type.id, OUTGO, date)
      instance_variable_set("#{name}", @recs)
      sum = 0
      @recs.each do |rec|
        sum += rec['amount'] ? rec['amount'] : 0
      end
      sum_name = "@outgo_sum_" + type.id.to_s
      instance_variable_set("#{sum_name}", sum)
    end
  end
end
