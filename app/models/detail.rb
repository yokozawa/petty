class Detail < ActiveRecord::Base
  belongs_to :user
  belongs_to :type
  belongs_to :meta

  validates :desc, presence: true
end
