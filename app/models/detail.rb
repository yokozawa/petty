class Detail < ActiveRecord::Base
  belongs_to :user
  belongs_to :type
  belongs_to :outline

  validates :type, presence: true
  validates :amount, presence: true

  def self.get_records_by_filter(type_id = false, sign = 1, date = false)
    if !type_id
      return false
    end
    if !date
      today = Date.today
      date = sprintf("%04d-%02d", today.year, today.month)
    end

    return self.find_by_sql([_create_sql, date, type_id, sign])
  end

  private
  def self._create_sql
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

end
