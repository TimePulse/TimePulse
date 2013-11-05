FactoryGirl.define  do
  factory :group do
    sequence(:name) {|n| "group_#{n}"}
  end
  factory :admin_group, :parent => :group do
    name "Administration"
  end
end

