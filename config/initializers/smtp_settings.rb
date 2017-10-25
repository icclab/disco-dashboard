ActionMailer::Base.delivery_method = :smtp

if (ENV['smtp_username'].nil? || ENV['smtp_username'].empty?) && (ENV['smtp_password'].nil? || ENV['smtp_password'].empty?) && (ENV['domain'].nil? || ENV['domain'].empty?)
  ActionMailer::Base.smtp_settings = {
      :enable_starttls_auto => ENV['smtp_enable_starttls_auto'],
      :address => ENV['smtp_server'],
      :port => ENV['smtp_port'].to_i,
      :authentication => :plain
  }
else
  ActionMailer::Base.smtp_settings = {
      :enable_starttls_auto => ENV['smtp_enable_starttls_auto'],
      :address => ENV['smtp_server'],
      :port => ENV['smtp_port'].to_i,
      :authentication => :plain,
      :domain => ENV['smtp_domain'],
      :user_name => ENV['smtp_username'],
      :password => ENV['smtp_password']
  }
end