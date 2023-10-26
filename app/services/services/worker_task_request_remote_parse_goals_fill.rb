# frozen_string_literal: true

module Services
  class WorkerTaskRequestRemoteParseGoalsFill
    def call
      RemoteParseGoal::GOAL_TEMPLATES.each do |goal|
        genre = Genre.find_by(int_id: goal['genre_int_id'])
        create_remote_parse_goal(genre, goal) if genre
      end
      check_goals
    end

    private

    def create_remote_parse_goal(genre, goal)
      RemoteParseGoal.create(
        genre: genre,
        order: goal['order'],
        limit: goal['limit'],
        date: calculate_date(goal),
        wday: goal['wday'],
        hour: goal['hour'],
        min: goal['min'],
        weeks_delay: goal['weeks_delay']
      )
    end

    def calculate_date(goal)
      days_count = goal['wday'] + (1.week.in_days.to_i * goal['weeks_delay']) - Time.zone.now.wday
      days_count += 1.week.in_days.to_i if days_count < RemoteParseGoal::DAYS_DELAY
      date = Time.zone.now + days_count.day
      "#{date.year}-#{date.month}-#{date.day} #{goal['hour']}:#{goal['min']}:00".to_datetime
    end

    def check_goals
      RemoteParseGoal.all.count == RemoteParseGoal::GOAL_TEMPLATES.size
    end
  end
end
