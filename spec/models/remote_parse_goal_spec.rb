require 'rails_helper'

RSpec.describe RemoteParseGoal, type: :model do
  it { should belong_to :genre }
  
  it { should validate_presence_of :order }
  it { should validate_presence_of :limit }
  it { should validate_presence_of :date }
  it { should validate_presence_of :wday }
  it { should validate_presence_of :hour }
  it { should validate_presence_of :min }

  it { should validate_numericality_of(:limit).is_greater_than(0) }
  it { should validate_numericality_of(:wday).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(6) }
  it { should validate_numericality_of(:hour).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(23) }
  it { should validate_numericality_of(:min).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(59) }
  it { should validate_numericality_of(:weeks_delay).is_greater_than_or_equal_to(0) }
end

