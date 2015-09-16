module ApplicationHelper
  NONE = :none_format
  def format_delta(delta)
    return '' if delta == NONE || delta == 0
    sign = delta > 0 ? '+' : '-'
    "#{sign}#{delta.to_i.abs/60}"
  end
  def format_time(time)
    time.getlocal.strftime('%H:%M')
  end

  def travel_format(travel)
    return '' unless travel
    theo = travel.theorically_enter_at
    last_str = travel.times.last
    radar_status = 'unseen'
    if last_str
      last = Time.parse(last_str[0..-7])
      radar_status = 'SEEN'
    end
    real = last || theo
    delta = NONE unless real && last
    delta ||= last - theo
    
    "#{travel.mission} #{travel.num} #{format_time(real)} #{format_delta(delta)} #{travel.status} #{radar_status}"
  end
end
