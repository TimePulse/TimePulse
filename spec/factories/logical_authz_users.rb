FactoryGirl.define  do
  factory :authz_account , :class => User do
    name "Quentin Johnson"
    sequence(:email) {|n| "quentin#{n}@sanquentin.penitentary.com"}
    sequence(:login) {|n| "quentin#{n}" }
    password "123456"
    password_confirmation "123456"
  end
end

FactoryGirl.define  do
  factory :authz_admin, :parent => :authz_account do
    groups {|u| [ association(:admin_group) ]}
  end
end
