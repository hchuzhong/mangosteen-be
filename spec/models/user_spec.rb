require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has email' do
    user = User.new email: 'hcz@test.com'
    expect(user.email).to eq 'hcz@test.com'
  end
end
