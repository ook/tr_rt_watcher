class TravelsController < ApplicationController
  def index
    from = params[:from]
    to = params[:to]

    to ||= Time.zone.beginning_of_day
    from ||= to

    start_station = params[:start_station]
    start_station = '87381798' # VAR
    end_station = params[:end_station]
    end_station = '87384008' # PSL

    #@travels = Travel.where(
  end
end
