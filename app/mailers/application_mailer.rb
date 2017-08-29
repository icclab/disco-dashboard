
class ApplicationMailer < ActionMailer::Base
  default from: 'disco.framework@gmail.com'
  layout 'mailer'

  def send_mail(receiver, subject, mailtext)
    @mailtext = mailtext
    mail(to: receiver, subject: subject)
  end
end
