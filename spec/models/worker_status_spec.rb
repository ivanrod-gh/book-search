require 'rails_helper'

RSpec.describe WorkerStatus, type: :model do
  it { should validate_presence_of :try }

  it { should validate_numericality_of(:try).is_greater_than_or_equal_to(0) }
end
