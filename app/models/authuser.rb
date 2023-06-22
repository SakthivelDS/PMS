class Authuser < ApplicationRecord
    validates :username, uniqueness: {case_sensitive:false}, presence: true
    validates :password, presence: true
    has_secure_password
    belongs_to :user_detail, optional: true
end
