require 'rails_helper'

RSpec.describe LimitedWorkerJob, type: :job do
  let(:service) { double('Services::Worker') }

  it 'call Services::Worker a certain number of times' do
    allow_any_instance_of(LimitedWorkerJob).to receive(:sleep)
    allow(service).to receive(:call).and_return(true)
    expect(Services::Worker).to receive(:new).exactly(LimitedWorkerJob::ITERATIONS_COUNT).times.and_return(service)
    LimitedWorkerJob.perform_now
  end

  it 'call Services::Worker only once if it responding \'stop_worker_job\'' do
    allow(service).to receive(:call).and_return('stop_worker_job')
    expect(Services::Worker).to receive(:new).and_return(service)
    LimitedWorkerJob.perform_now
  end
end
