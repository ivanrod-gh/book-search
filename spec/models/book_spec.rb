require 'rails_helper'

RSpec.describe Book, type: :model do
  it { should have_many(:book_genres).dependent(:destroy) }
  it { should have_many(:genres).through(:book_genres).source(:genre) }
  it { should have_many(:book_authors).dependent(:destroy) }
  it { should have_many(:authors).through(:book_authors).source(:author) }

  it { should validate_presence_of :int_id }
  describe "validate uniqueness of int_id" do
    subject { Book.new(int_id: 'int_id') }
    it { should validate_uniqueness_of(:int_id) }
  end
end
