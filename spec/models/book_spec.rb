require 'rails_helper'

RSpec.describe Book, type: :model do
  describe '.first_and_last_date_added' do
    let(:default_dates) do
      {
        start_date_added: Date.new(2000),
        end_date_added: Date.new(2000),
      }
    end
    let(:book_dates) do
      {
        start_date_added: Date.new(1987),
        end_date_added: Date.new(2123),
      }
    end
    let(:books_with_dates_added) do
      create(:book, :date_added_1998)
      create(:book, :date_added_2009)
      create(:book, :date_added_2025)
    end
    let(:clear_book_dates_added_list) { Book.dates_added_list = nil }

    describe 'respond with' do
      before { clear_book_dates_added_list }

      it 'default dates if no book exist' do
        puts "111111111111111"
        p Book.first_and_last_date_added
        p default_dates
        expect(Book.first_and_last_date_added).to eq default_dates
      end

      it 'book dates if books exist' do
        books_with_dates_added
        
        puts "2222222222222"
        p Book.first_and_last_date_added
        p book_dates
        expect(Book.first_and_last_date_added).to eq book_dates
      end
    end
  end

  it { should have_many(:book_genres).dependent(:destroy) }
  it { should have_many(:genres).through(:book_genres).source(:genre) }
  it { should have_many(:book_authors).dependent(:destroy) }
  it { should have_many(:authors).through(:book_authors).source(:author) }
  it { should have_many(:book_ratings).dependent(:destroy) }
  it { should have_many(:user_books).dependent(:destroy) }
  it { should have_one(:litres_book_rating).conditions(rating_id: Rating::INSTANCES['litres'].id)
    .class_name('BookRating') }
  it { should have_one(:livelib_book_rating).conditions(rating_id: Rating::INSTANCES['livelib'].id)
    .class_name('BookRating') }

  it { should validate_presence_of :int_id }
  describe "validate uniqueness of int_id" do
    subject { Book.new(int_id: 'int_id') }
    it { should validate_uniqueness_of(:int_id) }
  end
end
