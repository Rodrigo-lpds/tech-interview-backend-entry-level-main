require 'sidekiq-scheduler'

class MarkCartAsAbandonedScheduler
  include Sidekiq::Job

  def perform
    MarkCartAsAbandonedJob.perform_async
  end
end