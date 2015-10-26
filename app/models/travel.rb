class Travel < ActiveRecord::Base
  DATE_STR_FORMAT = '%Y%m%d'

  default_scope { order('date_str, theorically_enter_at') }

  class << self
    def add_travel(train:, stop:)
      stop_id = "StopPoint:DUA#{stop[0..-2]}"
      date_str = Time.now.strftime(DATE_STR_FORMAT)
      travel  = Travel.where(stop_id: stop_id, num: train.numero, date_str: date_str).first
      unless travel
        travel = new
        travel.num     = train.numero
        travel.mission = train.mission
        travel.term    = train.terminus
        # how to guess the direction, pattern matching?

        travel.date_str = date_str
        travel.stop_sequence = -1
        travel.stop_id = "StopPoint:DUA#{stop[0..-2]}"
        travel.status  = 'FETCH:DISCOVER'
      end
      travel.times << train.departure_at.localtime
      travel.save!
      travel
    end

    def today
      where(date_str: Time.now.strftime(DATE_STR_FORMAT))
    end

    def unseen
      where(times: '{}')
    end
    def seen
      where('times <> ?', '{}')
    end
  end


  def max_delta
    real_times = times.map { |t| Time.parse(t) }
    min = real_times.min
    max = real_times.max
    (max - min).to_i / 60
  end

  def final_delta
    first_time = Time.parse(theorically_enter_at)
    last_time  = Time.parse(times[-1])
    (last_time - first_time).to_i / 60
  end
end
