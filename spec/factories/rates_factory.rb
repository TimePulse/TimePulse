Factory.define :rate do |rate|
  rate.name "amount for name"
  rate.amount 100
  rate.association :project
end

Factory.define :rates_user do |r_u|
  r_u.association :rate
  r_u.association :user
end
