require 'rails_helper'

RSpec.describe UserBook, type: :model do
  it { should belong_to :user }
  it { should belong_to :book }
end
