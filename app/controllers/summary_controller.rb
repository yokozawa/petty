class SummaryController < ApplicationController
  def index
    @types = Type.all;

    @income_sum = 0
    @types.each do |type|
      name = sprintf("@recs_%d_%d", type.id, 0)
      @recs = Detail.get_records_by_filter(type.id, 0)
      eval("#{name} = @recs")
      @recs.each do |rec|
        @income_sum += rec['amount'] ? rec['amount'] : 0 
      end

      name = sprintf("@recs_%d_%d", type.id, 1)
      @recs = Detail.get_records_by_filter(type.id, 1)
      eval("#{name} = @recs")
      sum = 0
      @recs.each do |rec|
        sum += rec['amount'] ? rec['amount'] : 0
      end
      sum_name = sprintf("@outcome_sum_%d", type.id)
      eval("#{sum_name} = sum")
    end
  end
end
