class UserMailer < ApplicationMailer
    def welcome_email(code)
        @code = code
        mail(to:'352995096@qq.com', subject: 'Welcome to My Awesome Site')
    end
end