# frozen_string_literal: true

class Rating < ApplicationRecord
  INSTANCES = {
    'litres' => (Rating.find_by(name: 'litres') || Rating.create(name: 'litres')),
    'livelib' => (Rating.find_by(name: 'livelib') || Rating.create(name: 'livelib'))
  }.freeze

  has_many :book_ratings, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
