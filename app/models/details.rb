class Details < ActiveRecord::Base
  belongs_to :user_id
  belongs_to :type
  belongs_to :meta
end
