# frozen_string_literal: true

class LimitedWorkerJob < ApplicationJob
  # При использовании Services::Worker без 'живого' парсинга удаленных данных нет нужды запускать его
  # в бесконечном цикле (крон и т.п.)
  # По этой причине используется LimitedWorkerJob с задачей на выполнение воркера фиксированное количество раз
  # После выполнения всех работает воркер прерывает выполнение LimitedWorkerJob
  ITERATIONS_COUNT = 15

  queue_as :default

  def perform
    ITERATIONS_COUNT.times do
      return unless stop_job?(Services::Worker.new.call)

      sleep(Services::Worker::MINIMUM_COOLDOWN)
    end
  end

  private

  def stop_job?(respond)
    respond != 'stop_worker_job'
  end
end
