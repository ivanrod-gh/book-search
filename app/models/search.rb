# frozen_string_literal: true

class Search < ApplicationRecord
  belongs_to :user

  default_scope { order(updated_at: :desc) }
end
