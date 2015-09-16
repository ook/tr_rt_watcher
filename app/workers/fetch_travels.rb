require 'transilien_realtime'
class FetchTravels
  include Sidekiq::Worker

  MANDATORY_ENV = %w(RTT_API_USER RTT_API_PWD)
  def setup_worker
    @user, @pwd = *MANDATORY_ENV.map { |key| ENV[key] }
    raise ArgumentError, "ENV var: #{MANDATORY_ENV} are mandatory" unless @user && @pwd
    @tr = TransilienRealtime::Base.new(user: @user, pwd: @pwd)
  end

  def perform(from: '87381798', to: '87384008')
    setup_worker
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
