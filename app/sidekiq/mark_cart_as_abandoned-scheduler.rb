require 'sidekiq-scheduler'

class MarkCartAsAbandoned
  include Sidekiq::Job

  def perform
    MarkCartAsAbandonedJob.perform_async
  end
end