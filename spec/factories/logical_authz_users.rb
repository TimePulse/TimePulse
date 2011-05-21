Factory.define :authz_account , :class => User do |u|
  u.name "Quentin Johnson"
  u.sequence(:email) {|n| "quentin#{n}@sanquentin.penitentary.com"}
  u.sequence(:login) {|n| "quentin#{n}" }
  u.password "123456"
  u.password_confirmation "123456"
end

Factory.define :authz_admin, :parent => :authz_account do |u|
  u.groups {|u| [ u.association(:admin_group) ]}
end
