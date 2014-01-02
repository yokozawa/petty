class SummaryController < ApplicationController
  def index
    @types = Type.all;

    
    @recs = ActiveRecord::Base.connection.select_all("
      select strftime('%Y-%m-%d', d.record_at) record_date
            ,t.id type_id
            ,d.sign sign
            ,sum(d.amount) amount
        from details d
       inner join types t
          on d.type_id = t.id
       where strftime('%Y-%m', d.record_at) = '2014-01'
       group by strftime('%Y/%m/%d', d.record_at), t.id, d.sign
       order by 1 asc, 2 asc
    ")
  end
end
