class Detail < ActiveRecord::Base
  belongs_to :user
  belongs_to :type
  belongs_to :outline

  validates :type, presence: true
  validates :amount, presence: true

  def self.get_current_year_month
    today = Date.today
    date = sprintf("%04d-%02d", today.year, today.month)
  end

  def self.get_records_by_filter(type_id = false, sign = OUTGO, date = false)
    if !type_id
      return false
    end
    if !date
      date = get_current_year_month
    end
    return self.find_by_sql([_sql_for_records_by_filter, date, type_id, sign])
  end

  def self.get_current_income(user_id = false, date = false)
    return self.find_by_sql([_sql_for_current_amount, user_id, get_current_year_month, INCOME, user_id])
  end
  
  def self.get_current_outgo(user_id = false, date = false)
    return self.find_by_sql([_sql_for_current_amount, user_id, get_current_year_month, OUTGO, user_id])
  end

  private
  def self._sql_for_records_by_filter
    sql = "
	SELECT ADDDATE(DATE(DATE_FORMAT(NOW(), '%y-%m-01')), n.count) date
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
	       WHERE DATE_FORMAT(d.record_at, '%Y-%m') = ?
	         AND d.type_id = ?
	         AND d.sign = ?
	       GROUP BY DATE_FORMAT(d.record_at, '%Y/%m/%d'), d.type_id, d.sign
	       ORDER BY 1 ASC
	  ) d
	    ON ADDDATE(DATE(DATE_FORMAT(NOW(), '%y-%m-01')), n.count) = d.record_date
	 WHERE n.count <= DAYOFMONTH((DATE(DATE_FORMAT(CURRENT_DATE(), '%y-%m-01')) + INTERVAL 1 MONTH) - INTERVAL 1 DAY)
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
