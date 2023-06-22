class Payment < ApplicationRecord
    belongs_to :user_detail
    validates :approval_user, presence: true, length: {minimum: 3, maximum: 25}
end
