module RtTrWatcherWorker
  def redis
    @redis ||= TrRtWatcher.redis
  end

  def setup_worker_key(keys=[])
    @worker_key = begin
      suffix = keys.map { |k| k || 'nil' }.join('-')
      "#{self.class.name}-#{suffix}"
    end
  end

  def worker_key
    raise "Please call setup_worker_key" if @worker_key.nil?
    @worker_key
  end

  def track_in_redis(expire_delay = 30.second)
    milli = redis.get(worker_key).to_i
    return :must_stop if milli != 0 && Time.now.to_i <= milli
    redis.watch(worker_key) do
      multi_ret = redis.multi do
        redis.set(worker_key, Time.now.to_i + expire_delay)
      end
      return :must_stop if multi_ret.nil?
    end
  end

  def clean_redis
    redis.del(worker_key)
  end
end
