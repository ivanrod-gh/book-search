class WorkerTask < ApplicationRecord
  validates :name, :data, presence: true
end
