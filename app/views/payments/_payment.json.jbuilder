json.extract! payment, :id, :approval_user, :created_at, :updated_at
json.url payment_url(payment, format: :json)
