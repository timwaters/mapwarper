# Email settings
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => "mail.geothings.net",
  :port => 25,
  :domain => "warper.geothings.net",
  :username => ""

}
