require 'rails_helper'

RSpec.describe Ability, type: :model do
  subject(:ability) { Ability.new(user) }

  describe 'for guest' do
    let(:user) { nil }

    it { should     be_able_to :index, Search }
    it { should     be_able_to :full_text, Search }
    it { should     be_able_to :with_filters, Search }
    it { should_not be_able_to :read, :all }
    it { should_not be_able_to :manage, :all }
  end

  describe 'for user' do
    let(:user) { create :user }

    it { should     be_able_to :index, Search }
    it { should     be_able_to :full_text, Search }
    it { should     be_able_to :with_filters, Search }
    it { should     be_able_to :retrieve_old_search, Search }
    it { should     be_able_to :profile, User }
    it { should     be_able_to :books_shelf, User }
    it { should     be_able_to :books_show, User }
    it { should     be_able_to :create, UserBook }
    it { should     be_able_to :destroy, UserBook }
    it { should     be_able_to :destroy_all, UserBook }
    it { should_not be_able_to :read, :all }
    it { should_not be_able_to :manage, :all }
  end
end
