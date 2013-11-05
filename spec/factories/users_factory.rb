Factory.define :user , :class => User do |u|
  u.name "Quentin Johnson"
  u.sequence(:login) { |n| "quentin#{n}"}
  u.password "foobar"
  u.password_confirmation "foobar"
  u.inactive false

  #TODO: Fix this when LAz for R3 is ready.
  u.sequence(:email) {|n| "quentin#{n}@example.com"}
  u.sequence(:reset_password_token) { |n| "hYggoHueyySp#{n}czmffos" }
  u.sequence(:reset_password_sent_at) { |n| n.weeks.ago }

  u.sequence(:remember_created_at) { |n| n.weeks.ago}

  u.sequence(:sign_in_count) { |n| n}
  u.sequence(:current_sign_in_at) { |n| n.weeks.ago}
  u.sequence(:last_sign_in_at) { |n| (n+1).weeks.ago }
  u.sequence(:current_sign_in_ip) { |n| "192.168.0.#{n}"}
  u.sequence(:last_sign_in_ip) { |n| "192.168.0.#{n+1}"}

  u.sequence(:confirmation_token) { |n| "Q#{n}g5di9Q3GKGxHX4YzjM"}
  u.sequence(:confirmed_at) { |n| n.weeks.ago}
  u.sequence(:confirmation_sent_at) { |n| (n+1).weeks.ago }

  u.github_user "quentinjohnson"
  u.pivotal_name "Quentin Johnson"
end

Factory.define :admin, :parent => :user do |u|
  u.name "Administrator"
  u.sequence(:login) { |n| "administrator#{n}" }

  #TODO: Fix this when LAz for R3 is ready.
  u.admin true
end


