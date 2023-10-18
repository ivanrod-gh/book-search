# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ? user_abilities : guest_abilities
  end

  private

  def guest_abilities
    can %i[index full_text with_filters], Search
  end

  def user_abilities
    can %i[index full_text with_filters retrieve_old_search], Search
    can %i[profile books_shelf books_show], User
    can %i[create destroy destroy_all], UserBook
  end
end
