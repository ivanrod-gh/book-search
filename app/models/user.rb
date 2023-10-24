# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :omniauthable, omniauth_providers: %i[github]

  has_many :user_books, dependent: :destroy
  has_many :books, through: :user_books, source: :book
  has_many :searches, dependent: :destroy
  has_many :authorizations, dependent: :destroy
end
