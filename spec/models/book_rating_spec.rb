require 'rails_helper'

RSpec.describe BookRating, type: :model do
  it { should belong_to :book }
  it { should belong_to :rating }

  it { should validate_presence_of :average }
  it { should validate_presence_of :votes_count }
end
