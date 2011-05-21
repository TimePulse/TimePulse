FROM_ADDRESS     = "noreply@example.com"
REPLY_TO_ADDRESS = "noreply@example.com"

ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "lrdesign.com",
  :user_name            => "test@lrdesign.com",
  :password             => "xxxxxxx",
  :authentication       => :plain,
  :raise_delivery_errors => (Rails.env.development?),
  :enable_starttls_auto => true
}


class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    message.to      = "xxxxxx@lrdesign.com"   # Set this to your email address for development!
  end
end

ActionMailer::Base.default_url_options[:host] = "localhost:3000"
ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?