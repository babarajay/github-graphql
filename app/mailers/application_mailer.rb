class ApplicationMailer < ActionMailer::Base
  default from: 'kaizenapp123@gmail.com'
  layout 'mailer'

  def send_csv(email, timestamp)
    attachments['repositories.csv'] = { mime_type: 'text/csv', content: File.read("#{Rails.root}/tmp/#{timestamp}.csv") }
    mail(to: email, subject: 'GitHub repositories', body: 'Please find attachment.')
  end
end
