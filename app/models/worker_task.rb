# frozen_string_literal: true

class WorkerTask < ApplicationRecord
  validates :name, :data, presence: true
end
