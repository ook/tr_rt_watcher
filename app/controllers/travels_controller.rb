class TravelsController < ApplicationController
  def index
    from = params[:from]
    to = params[:to]

    to ||= Time.zone.now.beginning_of_day
    from ||= to

    @start_station = params[:start_station]
    @start_station ||= '87381798' # VAR
    @end_station = params[:end_station]
    @end_station = '87384008' # PSL
    @at = params[:at]
    @at ||= Time.zone.now - 20.minutes

    @travels = Travel.where(stop_id: "StopPoint:DUA#{@start_station[0..-2]}")
                     .where('theorically_enter_at >= ? AND theorically_enter_at <= ?', @at, @at + 1.hour)
  end
end
