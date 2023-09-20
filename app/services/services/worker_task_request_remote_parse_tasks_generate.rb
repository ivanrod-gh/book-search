# frozen_string_literal: true

module Services
  class WorkerTaskRequestRemoteParseTasksGenerate
    def call
      RemoteParseGoal.where("? > date", Time.zone.now).each do |goal|
        Book.where("date > '1970-01-01'").joins(:genres).where(genres: { id: goal.genre_id })
            .order(int_id: goal.order.to_sym).limit(goal.limit).each do |book|
          Services::WorkerTaskCreate.new.remote_page_parse(book) unless remote_parse_task_exists?(book)
        end
        goal.update(date: calculate_date(goal))
      end
      log_tasks_count
      goals_updated?
    end

    private

    def remote_parse_task_exists?(book)
      WorkerTask.where(name: 'remote_page_parse').where(data: { 'int_id' => book.int_id }.to_json).count.positive?
    end

    def calculate_date(goal)
      days_count = goal.wday + (1.week.in_days.to_i * goal.weeks_delay) - Time.zone.now.wday
      days_count += 1.week.in_days.to_i if days_count < RemoteParseGoal::DAYS_DELAY
      date = Time.zone.now + days_count.day
      "#{date.year}-#{date.month}-#{date.day} #{goal.hour}:#{goal.min}:00".to_datetime
    end

    def log_tasks_count
      Rails.logger.info "Added (#{WorkerTask.where(name: 'remote_page_parse').count}) tasks for remote page parsing"
    end

    def goals_updated?
      RemoteParseGoal.where("? < date", 10.seconds.ago).count.positive?
    end
  end
end
