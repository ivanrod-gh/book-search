# frozen_string_literal: true

class UserBook < ApplicationRecord
  MAXIMUM_USER_BOOKS_COUNT_PER_USER = 250

  belongs_to :user
  belongs_to :book

  validates :user, uniqueness: { scope: :book }

  validate :user_books_count

  default_scope { order(created_at: :desc) }

  private

  def user_books_count
    return unless user && user.books.count >= MAXIMUM_USER_BOOKS_COUNT_PER_USER

    errors.add(:maximum_books_count, "Книжная полка имеет ограничение в #{MAXIMUM_USER_BOOKS_COUNT_PER_USER} книг")
  end
end
