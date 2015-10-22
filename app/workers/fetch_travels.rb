require 'transilien_realtime'
class FetchTravels
  include Sidekiq::Worker

  MANDATORY_ENV = %w(RTT_API_USER RTT_API_PWD)
  def redis
    @redis ||= TrRtWatcher.redis
  end

  def setup_worker
    @user, @pwd = *MANDATORY_ENV.map { |key| ENV[key] }
    raise ArgumentError, "ENV var: #{MANDATORY_ENV} are mandatory" unless @user && @pwd
    @tr = TransilienRealtime::Base.new(user: @user, pwd: @pwd)
  end

  def worker_key
    @worker_key ||= "#{self.class.name}-#{@from}-#{@to||'nil'}"
  end

  EXPIRE_DELAY = 30.second
  def track_in_redis
    milli = redis.get(worker_key).to_i
    return :must_stop if milli != 0 && Time.now.to_i <= milli
    redis.watch(worker_key) do
      multi_ret = redis.multi do
        redis.set(worker_key, Time.now.to_i + EXPIRE_DELAY)
      end
      return :must_stop if multi_ret.nil?
    end
  end

  def clean_redis
    redis.del(worker_key)
  end

  #def perform(from: '87381798', to: '87384008')
  def perform(from: '87381798', to: nil)
    setup_worker
    @from = from
    @to = to
    if :must_stop == track_in_redis # End tje worker right now
      logger.warn("Discover that we MUST STOP. Certainly a duplicated request.")
      return true
    end
    #@tr.next(from: from, to: to)
    @tr.next(from: from)
    @tr.trains.each do |train|
      t = Travel.add_travel(train: train, stop: from)
      puts t.inspect
      #puts t.max_delta
      #puts t.final_delta
    end
    FetchTravels.perform_in(1.minute)
  end
end
