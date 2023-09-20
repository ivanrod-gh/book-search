# frozen_string_literal: true

class WorkerStatus < ApplicationRecord
  validates :try, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
