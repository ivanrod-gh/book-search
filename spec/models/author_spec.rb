require 'rails_helper'

RSpec.describe Author, type: :model do
  it { should have_many(:book_authors).dependent(:destroy) }
  it { should have_many(:books).through(:book_authors).source(:book) }

  it { should validate_presence_of :int_id }
  describe "validate uniqueness of int_id" do
    subject { Author.new(int_id: 'int_id', name: 'name') }
    it { should validate_uniqueness_of(:int_id) }
  end
  it { should validate_presence_of :name }
end

