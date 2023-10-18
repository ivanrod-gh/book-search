require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:user_books).dependent(:destroy) }
  it { should have_many(:books).through(:user_books).source(:book) }
  it { should have_many(:searches).dependent(:destroy) }
end
