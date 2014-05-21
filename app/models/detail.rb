class Detail < ActiveRecord::Base
  belongs_to :user
  belongs_to :type
  belongs_to :outline

  validates :type, presence: true
  validates :amount, presence: true

  after_save :calc_card_amount

  def self.get_current_income(type_id)
    date = Date.today if !date
    from = date.beginning_of_month
    where(:type_id => type_id, :sign => INCOME, record_at: from .. date).sum(:amount)
  end

  def self.get_current_outgo(type_id)
    date = Date.today if !date
    from = date.beginning_of_month
    where(:type_id => type_id, :sign => OUTGO, record_at: from .. date).sum(:amount)
  end

  def calc_card_amount
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

end
