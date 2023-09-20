require 'rails_helper'

RSpec.describe Services::Worker do
  let(:worker_status_with_cooldown) { create(:worker_status, :with_cooldown) }
  let(:worker_status_with_started_at_just_now) { create(:worker_status, :with_started_at_just_now) }
  let(:worker_status_with_pid) { create(:worker_status, :with_pid) }
  let(:worker_status_with_reason_403_and_1_try) { create(:worker_status, :with_reason_403_and_1_try) }
  let(:task_unzip_simple) { create(:worker_task, :unzip_simple) }
  let(:book) { create(:book) }
  let(:task_remote_parse) { create(:worker_task, :remote_parse) }
  let(:nokigiri_bad_downloaded_page) { Nokogiri::HTML(File.open('spec/files/page_bad.html')) }
  let(:remote_parse_goal_with_actual_date) { create(:remote_parse_goal, :with_actual_date) }
  
  it 'create worker status instance for self-management' do
    expect{ Services::Worker.new.call }.to change(WorkerStatus, :count).by(1)
  end

  it 'do nothing if worker status instance has cooldown' do
    worker_status_with_cooldown
    expect_any_instance_of(Services::Worker).not_to receive(:check_tasks)
    Services::Worker.new.call
  end

  it 'do nothing if worker status instance has pid and busy' do
    worker_status_with_pid
    expect_any_instance_of(Services::Worker).not_to receive(:check_tasks)
    Services::Worker.new.call
  end

  it 'add self-cooldown if worker execution service failed task and task status is \'empty page\'' do
    book
    task_remote_parse
    allow_any_instance_of(Services::RemotePageParse).to receive(:page).and_return(nokigiri_bad_downloaded_page)
    Services::Worker.new.call
    cooldowns = Services::Worker::COOLDOWN_TABLE_BY_REASON_AND_TRY['empty_page']
    expect(cooldowns.include?((WorkerStatus.first.cooldown_until - Time.zone.now).round(0))).to eq true
  end

  it 'add self-cooldown if worker execution service raise exception and task status is \'403\'' do
    book
    task_remote_parse
    allow_any_instance_of(Services::RemotePageParse).to receive(:page).and_raise(Exception, '403')
    Services::Worker.new.call
    cooldowns = Services::Worker::COOLDOWN_TABLE_BY_REASON_AND_TRY['403']
    expect(cooldowns.include?((WorkerStatus.first.cooldown_until - Time.zone.now).round(0))).to eq true
  end

  it 'increase self-cooldown if worker execution service raise exception again and reason was \'403\'' do
    book
    task_remote_parse
    worker_status_with_reason_403_and_1_try
    allow_any_instance_of(Services::RemotePageParse).to receive(:page).and_raise(Exception, '403')
    Services::Worker.new.call
    cooldown_403_with_1_try = Services::Worker::COOLDOWN_TABLE_BY_REASON_AND_TRY['403'][1]
    expect((WorkerStatus.first.cooldown_until - Time.zone.now).round(0)).to eq cooldown_403_with_1_try
  end

  it 'do nothing if worker status instance started just now and worker was rejected by minimum cooldown constant' do
    worker_status_with_started_at_just_now
    if Services::Worker::MINIMUM_COOLDOWN.positive?
      expect_any_instance_of(Services::Worker).not_to receive(:check_tasks)
    end
    Services::Worker.new.call
  end

  it 'call specific service if found specific worker task' do
    `cp spec/files/partners_utf.yml.gz #{JSON.parse(task_unzip_simple.data)['archive_name']}`
    expect(Services::PartnerDBUnzip).to receive(:new).with(task_unzip_simple).and_call_original
    expect{ Services::Worker.new.call }.to change(WorkerTask, :count).by(-1)
    File.delete(JSON.parse(task_unzip_simple.data)['file_name'])
  end

  it 'call request_d_b_fill service to create tasks to populate db if no book found' do
    expect(Services::WorkerTaskRequestDBFill).to receive(:new)
    Services::Worker.new.call
  end

  # Для получения некоторых данных вместо сервисов удаленного парсинга используется сервис генерации данных
  # it 'call request_remote_parse_goals_fill service if no remote parse goals found' do
  #   book
  #   expect(Services::WorkerTaskRequestRemoteParseGoalsFill).to receive(:new)
  #   Services::Worker.new.call
  # end

  # it 'call request_remote_parse_tasks_generate service when its time to generate remote parse tasks' do
  #   book
  #   remote_parse_goal_with_actual_date
  #   expect(Services::WorkerTaskRequestRemoteParseTasksGenerate).to receive(:new)
  #   Services::Worker.new.call
  # end

  it 'call generate_additional_book_data service to fill books with additional data' do
    book
    expect(Services::GenerateAdditionalBookData).to receive(:new)
    Services::Worker.new.call
  end

  it 'reset worker status (except \'started_at\') after successfully finishing iteration' do
    Services::Worker.new.call
    expect(WorkerStatus.first.pid).to eq nil
    expect(WorkerStatus.first.started_at).not_to eq nil
    expect(WorkerStatus.first.cooldown_until).to eq nil
    expect(WorkerStatus.first.cooldown_reason).to eq nil
    expect(WorkerStatus.first.try).to eq 0
  end
end
