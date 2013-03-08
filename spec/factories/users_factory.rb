Factory.define :user , :class => User do |u|
  u.name "Quentin Johnson"
  u.sequence(:login) { |n| "quentin#{n}"}
  u.password "foobar"
  u.password_confirmation "foobar"

  #TODO: Fix this when LAz for R3 is ready.
  u.groups{ [Group.find_by_name("Registered Users")] }
  u.sequence(:email) {|n| "quentin#{n}@example.com"}
end

Factory.define :admin, :parent => :user do |u|
  u.name "Administrator"
  u.sequence(:login) { |n| "administrator#{n}" }

  #TODO: Fix this when LAz for R3 is ready.
  u.groups{  [Group.find_by_name("Administration"), Group.find_by_name("Registered Users")] }
end


