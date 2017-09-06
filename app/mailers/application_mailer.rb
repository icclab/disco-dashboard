
class ApplicationMailer < ActionMailer::Base
  default from: 'disco.framework@gmail.com'
  layout 'mailer'

  def send_mail(receiver, subject, mailtext)
    @mailtext = mailtext
    mail(to: receiver, subject: subject, content_type: "text/plain")
  end
end
