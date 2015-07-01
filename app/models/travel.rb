class Travel < ActiveRecord::Base

  class << self
    def add_travel(train)
      travel  = Travel.where(num: train.numero).first
      unless travel
        travel = new
        travel.num     = train.numero
        travel.mission = train.mission
        travel.term    = train.terminus
      end
      travel.times << train.departure_at
      travel.save!
      travel
    end
  end

  def max_delta
    real_times = times.map { |t| Time.parse(t) }
    min = real_times.min
    max = real_times.max
    (max - min).to_i / 60
  end

  def final_delta
    first_time = Time.parse(times[0])
    last_time  = Time.parse(times[-1])
    (last_time - first_time).to_i / 60
  end
end
