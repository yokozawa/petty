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

  def self.get_current_income(type_id)
    date = Date.today if !date
    from = date.beginning_of_month
    Detail.where(:type_id => type_id, :sign => INCOME, record_at: from .. date).sum(:amount)
  end
  
  def self.get_current_outgo(type_id)
    date = Date.today if !date
    from = date.beginning_of_month
    Detail.where(:type_id => type_id, :sign => OUTGO, record_at: from .. date).sum(:amount)
  end

  def _calc_card_amount
    return if !self.type.is_card

    today = Date.today
    payment_date = sprintf("%04d-%02d-%02d", today.next_month.year, today.next_month.month, type.payment_day)

    rec = Detail.where("user_id = ? AND created_by = ? AND DATE_FORMAT(record_at, '%Y-%m-%d') = ?", self.user_id, type.id, payment_date).first_or_create do |d|
      d.user_id = self.user_id
      d.type_id = 1
      d.created_by = type.id
      d.record_at = payment_date
      d.sign = OUTGO
      d.desc = type.label
      d.save
    end

    to = if type.cutoff_day == GETSUMATSU
      today.end_of_month
    else 
      Date.new(today.year, today.month, type.cutoff_day)
    end
    from = to.prev_month.tomorrow
    summary = Detail.where(:user_id => self.user_id, :type_id => type.id, record_at: from .. to).sum(:amount)

    rec.amount = summary
    rec.save

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

end
