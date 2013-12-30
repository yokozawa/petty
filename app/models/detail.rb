class Detail < ActiveRecord::Base
  belongs_to :user
  belongs_to :type
  belongs_to :outline

  validates :desc, presence: true
end
