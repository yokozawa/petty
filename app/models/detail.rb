class Detail < ActiveRecord::Base
  belongs_to :user
  belongs_to :type
  belongs_to :outline

  validates :type, presence: true
  validates :amount, presence: true

  after_save :_calc_card_amount

  def self.get_current_year_month
    today = Date.today
    date = sprintf("%04d-%02d", today.year, today.month)
  end

  def self.get_records_by_filter(user_id = false, type_id = false, sign = OUTGO, date = false)
    return false if !type_id or !user_id
    date = get_current_year_month if !date
    first_day = sprintf("%s-01", date)
    return self.find_by_sql([_sql_for_records_by_filter, first_day, user_id, date, type_id, sign, first_day, first_day])
  end

  def self.get_current_income(user_id = false, date = false)
    date = get_current_year_month if !date
    return self.find_by_sql([_sql_for_current_amount, user_id, date, INCOME, user_id])
  end
  
  def self.get_current_outgo(user_id = false, date = false)
    date = get_current_year_month if !date
    return self.find_by_sql([_sql_for_current_amount, user_id, date, OUTGO, user_id])
  end

  def _calc_card_amount
    return if !self.type.is_card

#    today = Date.today
#    payment_date = sprintf("%04d-%02d-%02d", today.next_month.year, today.next_month.month, type.payment_day)
#    rec = Detail.find_by_sql([_sql_for_card_record, self.user_id, type.id, payment_date]).first

    today = Date.today
    payment_date = Date.new(today.next_month.year, today.next_month.month, self.type.payment_day)
    rec = Detail.find(:first, :conditions => {:user_id => self.user_id, :type_id => self.type.id, :record_at => payment_date})

    if type.cutoff_day == GETSUMATSU
      cutoff_date = sprintf("%04d-%02d-%02d", today.next_month.year, today.next_month.month, -1)
    else 
      cutoff_date = sprintf("%04d-%02d-%02d", today.year, today.month, type.cutoff_day)
    end
    summary = Detail.find_by_sql([_sql_for_card_summary, self.user_id, type.id, cutoff_date, cutoff_date]).first 

    if rec != nil
      rec.amount = summary.amount
      rec.save
    else
      detail = Detail.new(
        :user_id => self.user_id,
        :type_id => 1,
        :created_by => type.id,
        :amount => summary.amount,
        :record_at => payment_date,
        :sign => OUTGO,
        :desc => sprintf("%s", type.label)
      )
      detail.save
    end
  end

  private
  def self._sql_for_records_by_filter
    sql = "
	SELECT ADDDATE(DATE(DATE_FORMAT(?, '%Y-%m-01')), n.count) date
	       ,d.type_id
	       ,d.sign
	       ,d.amount
	  FROM num n
	  LEFT OUTER JOIN (
	      SELECT date_format(d.record_at, '%Y-%m-%d') record_date
	             ,d.type_id type_id
	             ,d.sign sign
	             ,sum(d.amount) amount
	        FROM details d
	       WHERE d.user_id = ?
             AND DATE_FORMAT(d.record_at, '%Y-%m') = ?
	         AND d.type_id = ?
	         AND d.sign = ?
	       GROUP BY DATE_FORMAT(d.record_at, '%Y/%m/%d'), d.type_id, d.sign
	       ORDER BY 1 ASC
	  ) d
	    ON ADDDATE(DATE(DATE_FORMAT(?, '%Y-%m-01')), n.count) = d.record_date
	 WHERE n.count <= DAYOFMONTH((DATE(DATE_FORMAT(?, '%Y-%m-01')) + INTERVAL 1 MONTH) - INTERVAL 1 DAY)
	 ORDER BY n.count ASC
    "
  end

  def self._sql_for_current_amount
    sql = "
      SELECT SUM(d.amount) amount
        FROM details d
       WHERE d.user_id = ?
         AND DATE_FORMAT(d.record_at, '%Y-%m') = ?
         AND d.record_at <= now()
         AND d.sign = ?
         AND d.type_id = (select min(id) from types where user_id = ?)
    "
  end 

  def _sql_for_card_record
    sql = "
      SELECT d.*
        FROM details d
       WHERE user_id = ?
         AND created_by = ?
         AND DATE_FORMAT(d.record_at, '%Y-%m-%d') = ?
    "
  end

  def _sql_for_card_summary
    sql = "
      SELECT sum(d.amount) amount
        FROM details d
       WHERE d.user_id = ?
         AND d.type_id = ?
         AND d.record_at <= DATE_FORMAT(?, '%Y-%m-%d')
         AND d.record_at >= (DATE_FORMAT(?, '%Y-%m-%d') - INTERVAL 1 MONTH)
    "
  end
end
