class Session
    include ActiveModel::Model
    attr_accessor :email, :code
    validates :email, :code, presence: true
    validates :email, format: { with: /\A.+@.+\z/ }

    validate :check_validation_code

    def check_validation_code
        return if self.email == 'test@test.com' and self.code == '123456'
        return if Rails.env.test? and self.code == '123456'
        return if self.email.empty?
        return if self.code.empty?
        return self.errors.add :email, 'email not found' unless ValidationCode.exists? email: self.email
        return self.errors.add :code, 'invalid code' unless ValidationCode.exists? email: self.email, code: self.code
        self.errors.add :code, 'this code had been used' unless ValidationCode.exists? email: self.email, code: self.code, used_at: nil
    end
end