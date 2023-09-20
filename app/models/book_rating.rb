# frozen_string_literal: true

class BookRating < ApplicationRecord
  belongs_to :book
  belongs_to :rating

  validates :average, :votes_count, presence: true
end
