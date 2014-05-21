class SummaryController < ApplicationController

  before_filter :authenticate_user!

  def index
    @types = current_user.types

    # get current cash
    @current_income = current_user.details.get_current_income(@types.minimum(:id))
    @current_outgo = current_user.details.get_current_outgo(@types.minimum(:id))

    # set target date and get target details
    t = if params[:y] and params[:m]
      date = sprintf("%04d-%02d", params[:y], params[:m])
      Time.parse(sprintf("%s-01", date))
    else
      Time.now
    end
    @days = (t.beginning_of_month.to_date..t.end_of_month.to_date).to_a
    @first_day_of_month = t.beginning_of_month.to_date

    @details = current_user.details.where(record_at: @days)

    # summary income
    income_summary = @details.where(sign: INCOME)
      .group('date_format(record_at, "%Y-%m-%d")').sum(:amount)
    @income_cash_key = "#{@types.minimum(:id)}-#{INCOME}"
    @day_summary = {}
    @month_summary = {}
    @month_summary.default = 0
    @days.each do |day|
      amounts = {}
      amounts.default = 0
      income_cash = income_summary[day.strftime("%Y-%m-%d")] || 0
      amounts[@income_cash_key] = income_cash
      @month_summary[@income_cash_key] += income_cash
      @day_summary[day] = amounts
    end

    # summary outgo
    @types.each do |type|
      outgo_summary = @details.where(sign: OUTGO, type_id: type.id)
        .group('date_format(record_at, "%Y-%m-%d")').sum(:amount)

      @days.each do |day|
        outgo_cash = outgo_summary[day.strftime("%Y-%m-%d")] || 0
        amounts = @day_summary[day]
        amounts[type.id] = outgo_cash
        @day_summary[day] = amounts
        @month_summary[type.id] += outgo_cash
      end
    end

  end

end
