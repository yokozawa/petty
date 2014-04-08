module TimePlus
  def days
    (1..Time.days_in_month(self.month)).to_a
  end
end

class Time
  include TimePlus
end