ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :enable_starttls_auto => ENV['smtp_enable_starttls_auto'],
    :address => ENV['smtp_server'],
    :port => ENV['smtp_port'].to_i,
    :authentication => :plain,
    :domain => ENV['smtp_domain'],
    :user_name => ENV['smtp_username'],
    :password => ENV['smtp_password']
}