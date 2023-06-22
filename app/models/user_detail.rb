class UserDetail < ApplicationRecord

    has_many :payments
    has_many :authusers
    validates :email, uniqueness: {case_sensitive: false}, format: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

    
end
