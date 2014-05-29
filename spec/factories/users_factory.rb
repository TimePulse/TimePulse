FactoryGirl.define  do
  factory :user , :class => User do
    name "Quentin Johnson"
    sequence(:login) { |n| "quentin#{n}"}
    password "foobar"
    password_confirmation "foobar"
    inactive false

    sequence(:email) {|n| "quentin#{n}@example.com"}
    sequence(:reset_password_token) { |n| "hYggoHueyySp#{n}czmffos" }
    sequence(:reset_password_sent_at) { |n| n.weeks.ago }

    sequence(:remember_created_at) { |n| n.weeks.ago}

    sequence(:sign_in_count) { |n| n}
    sequence(:current_sign_in_at) { |n| n.weeks.ago}
    sequence(:last_sign_in_at) { |n| (n+1).weeks.ago }
    sequence(:current_sign_in_ip) { |n| "192.168.0.#{n}"}
    sequence(:last_sign_in_ip) { |n| "192.168.0.#{n+1}"}

    sequence(:confirmation_token) { |n| "Q#{n}g5di9Q3GKGxHX4YzjM"}
    sequence(:confirmed_at) { |n| n.weeks.ago}
    sequence(:confirmation_sent_at) { |n| (n+1).weeks.ago }

    github_user "quentinjohnson"
    pivotal_name "Quentin Johnson"

    association :user_preferences
  end

  factory :admin, :parent => :user do
    name "Administrator"
    sequence(:login) { |n| "administrator#{n}" }

    admin true
  end

  factory :user_preferences do
    recent_projects_count 5
  end

end