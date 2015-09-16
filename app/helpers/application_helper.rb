module ApplicationHelper
  NONE = :none_format
  def format_delta(delta)
    return '' if delta == NONE || delta == 0
    sign = delta > 0 ? '+' : '-'
    "#{sign}#{delta.to_i.abs/60}"
  end
  def format_time(time)
    time.strftime('%H:%M')
  end

  def travel_format(travel)
    return '' unless travel
    theo = travel.theorically_enter_at
    last_str = travel.times.last
    last = last_str && Time.parse(last_str[0..-7])
    real = last || theo
    delta = NONE unless real && last
    delta ||= last - theo
    
    "#{travel.mission} #{travel.num} #{travel.status} #{format_time(real)} #{format_delta(delta)} #{last_str}|#{theo}"
  end
end
