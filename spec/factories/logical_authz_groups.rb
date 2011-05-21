Factory.define :group do |g| 
  g.sequence(:name) {|n| "group_#{n}"}
end

Factory.define :admin_group, :parent => :group do |g|
  g.name "Administration"
end
