require 'rails_helper'

RSpec.describe WorkerTask, type: :model do
  it { should validate_presence_of :name }
  it { should validate_presence_of :data }
end
