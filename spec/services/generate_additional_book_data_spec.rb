require 'rails_helper'

RSpec.describe Services::GenerateAdditionalBookData do
  let(:book) { create(:book, :date_added_2111) }
  # Необходимо, т.к. тестовая среда уничтожает данные Rating и замороженный хэш начинает указывать на пустое место
  let(:reinitialize_rating_instances_constant) do
    Rating::INSTANCES = {
      'litres' => (Rating.find_by(name: 'litres') || Rating.create(name: 'litres')),
      'livelib' => (Rating.find_by(name: 'livelib') || Rating.create(name: 'livelib'))
    }
  end

  it 'do nothing if no book exists' do
    Services::GenerateAdditionalBookData.new.call
    expect(Book.where("date >= '1970-01-01'").where("pages_count >= 0").count.positive?).to eq false
  end

  it 'add aditional book data if book exists' do
    reinitialize_rating_instances_constant
    book
    allow_any_instance_of(Services::GenerateAdditionalBookData).to receive(:end_of_iteration_reached?).and_return(false)
    Services::GenerateAdditionalBookData.new.call
    expect(Book.where("date >= '1970-01-01'").where("pages_count >= 0").count.positive?).to eq true
  end

  describe 'respond state to caller' do
    it 'return false when execution failed' do
      expect(Services::GenerateAdditionalBookData.new.call).to eq false
    end

    it 'return true when execution successful' do
      reinitialize_rating_instances_constant
      book
      allow_any_instance_of(Services::GenerateAdditionalBookData).to receive(:end_of_iteration_reached?).and_return(false)
      expect(Services::GenerateAdditionalBookData.new.call).to eq true
    end
  end
end
