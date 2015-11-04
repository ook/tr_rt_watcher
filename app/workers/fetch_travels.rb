require 'transilien_realtime'
class FetchTravels
  include Sidekiq::Worker
  include RtTrWatcherWorker

  MANDATORY_ENV = %w(RTT_API_USER RTT_API_PWD)

  def setup_worker
    @user, @pwd = *MANDATORY_ENV.map { |key| ENV[key] }
    raise ArgumentError, "ENV var: #{MANDATORY_ENV} are mandatory" unless @user && @pwd
    @tr = TransilienRealtime::Base.new(user: @user, pwd: @pwd)
  end

  #def perform(from: '87381798', to: '87384008')
  def perform(from = '87381798', to = nil)
    setup_worker
    @from = from
    @to = to
    setup_worker_key([@from, @to])
    if :must_stop == track_in_redis # End tje worker right now
      logger.warn("Discover that we MUST STOP. Certainly a duplicated request.")
      return true
    end
    #@tr.next(from: from, to: to)
    @tr.next(from: from)
    @tr.trains.each do |train|
      logger.info("stop=#{from} train=#{train.inspect}")
      t = Travel.add_travel(train: train, stop: from)
      puts t.inspect
      #puts t.max_delta
      #puts t.final_delta
    end
    FetchTravels.perform_in(1.minute)
  end
end
