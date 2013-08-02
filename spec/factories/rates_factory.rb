Factory.define :rate do |rate|
  rate.name "amount for name"
  rate.amount 1
  rate.project { |project| project.association(:project) }
end
