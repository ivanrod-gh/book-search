require 'rails_helper'

RSpec.describe Rating, type: :model do
  it { should have_many(:book_ratings).dependent(:destroy) }

  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
end
