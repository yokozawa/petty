class Type < ActiveRecord::Base
  belongs_to :user
  has_many :details

  scope :cash_id, -> { minimum(:id) }
end
