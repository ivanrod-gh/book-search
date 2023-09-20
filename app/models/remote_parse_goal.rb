# frozen_string_literal: true

class RemoteParseGoal < ApplicationRecord
  GOAL_TEMPLATES = [
    { 'genre_int_id' => '5073', 'order' => 'desc', 'limit' => 1000, 'wday' => 0,
      'hour' => 23, 'min' => 0, 'weeks_delay' => 0 },
    { 'genre_int_id' => '5095', 'order' => 'desc', 'limit' => 1000, 'wday' => 1,
      'hour' => 23, 'min' => 0, 'weeks_delay' => 0 },
    { 'genre_int_id' => '5232', 'order' => 'desc', 'limit' => 1000, 'wday' => 2,
      'hour' => 23, 'min' => 0, 'weeks_delay' => 0 },
    { 'genre_int_id' => '5259', 'order' => 'desc', 'limit' => 1000, 'wday' => 3,
      'hour' => 23, 'min' => 0, 'weeks_delay' => 0 },
    { 'genre_int_id' => '5296', 'order' => 'desc', 'limit' => 1000, 'wday' => 4,
      'hour' => 23, 'min' => 0, 'weeks_delay' => 0 }
  ].freeze

  DAYS_DELAY = 1

  belongs_to :genre

  validates :order, :limit, :date, :wday, :hour, :min, presence: true
  validates :limit, numericality: { greater_than: 0 }
  validates :wday, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }
  validates :hour, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
  validates :min, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 59 }
  validates :weeks_delay, numericality: { greater_than_or_equal_to: 0 }
end
