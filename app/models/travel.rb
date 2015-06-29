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
end
