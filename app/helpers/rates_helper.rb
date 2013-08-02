module RatesHelper
  def options_for_rates_users(rate)
    default_option = content_tag(:option, '- Add User -', :value => '')
    options = options_from_collection_for_select(@all_users, :id, :name, rate.users.map { |user| user.id })
    default_option + options
  end
end
