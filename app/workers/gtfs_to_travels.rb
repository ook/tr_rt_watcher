require 'gtfs'
require 'ostruct'

class GtfsToTravels
  include Sidekiq::Worker

  GTFS_URL = 'https://ressources.data.sncf.com/api/datasets/1.0/sncf-transilien-gtfs/attachments/export_tn_gtfs_last_zip/'

  ALL_KNOWN_SHORT_NAMES = %w(A B C D E H J K L N P R T4 U)
  DAYS = %w(sunday monday tuesday wednesday thursday friday saturday)

  def extract_date(date, time)
    date = date.dup
    hour, minutes = *time.split(':').map(&:to_i)
    if hour > 23
      date += 1
      hour - 24
    end
    day = date.to_time.to_i
    Time.at(day + (hour * 60 * 60) + (minutes * 60))
  end

  # DUASN493401R02001348720 -> 493401
  def extract_num(trip_id)
    trip_id[5..-1].to_i.to_s
  end

  def build_dates_for_services
    start_date = Time.now.beginning_of_month.strftime('%Y%m%d')
    end_date = (Time.now + 1.month).end_of_month.strftime('%Y%m%d')
    calendars = @source.calendars.select do |c|
      (c.start_date >= start_date && c.end_date <= start_date) ||
      (c.end_date >= end_date && c.start_date <= end_date )
    end
    services_id = calendars.map(&:service_id)
    calendars_dates = @source.calendar_dates.select { |cd| services_id.include?(cd.service_id) }
    s_by_d = {}
    calendars.map do |c|
      date_start = Date.parse(c.start_date)
      date_end   = Date.parse(c.end_date)
      (date_start..date_end).to_a.each do |date|
        next unless '1' == c.send(DAYS[date.wday])
        date_str = date.strftime('%Y%m%d')
        next if date_str < start_date || date_str > end_date
        s_by_d[c.service_id] ||= []
        s_by_d[c.service_id] << date_str
      end
    end
    s_by_d
  end

  def perform(short_names = ALL_KNOWN_SHORT_NAMES)
    puts short_names.inspect
    raise ArgumentError, "short_names: named arg SHOULD be an Array of String" unless short_names.is_a?(Array)
    puts "Loading GTFS: #{GTFS_URL}"
    @source = GTFS::Source.build(GTFS_URL)
    puts "Loading done."
    puts "Building services."
    @service_by_dates = build_dates_for_services
    puts "Services done."

    puts "Collecting routes…"
    @routes = @source.routes.select { |r| short_names.include?(r.short_name) }
    route_ids = @routes.map(&:id)
    puts "Routes done."

    puts "Collecting trips…"
    @trips = @source.trips.select { |t| route_ids.include?(t.route_id) }
    trip_ids = @trips.map(&:id)
    puts "Trips done."

    service_ids = @trips.map(&:service_id)
    puts "Service_ids collected."

    puts "Collecting stop_times…"
    @stop_times = @source.stop_times.select { |st| trip_ids.include?(st.trip_id) }
    puts "Stop times done."
    #@calendars = @source.calendars.select { |c| service_ids.include?(c.service_id) }
    puts "routes: #{@routes.length}"
    puts "trips: #{@trips.length}"
    #puts "calendars: #{@calendars.length}"
    puts "stop_times: #{@stop_times.length}"
    #puts @calendars.last.inspect
    #puts @stop_times.last.inspect

    puts
    puts

    travels = []

#<GTFS::Route:0x007fc1c07eb650 @id="DUA800854541", @agency_id="DUA854", @short_name="J", @long_name="Gare St-Lazare - Ermont Eaubonne /
#Vernon / Gisors", @desc=nil, @type="3", @url=nil, @color="CDCD00", @text_color=nil>
##<GTFS::Trip:0x007fc1befe2040 @route_id="DUA800854541", @service_id="11752", @id="DUASN493401R02001348720", @headsign="93401",
#@direction_id="1", @block_id=nil>
##<GTFS::StopTime:0x007fc201783280 @trip_id="DUASN493401R02001348720", @arrival_time="22:42:00", @departure_time="22:42:00",
#@stop_id="StopPoint:DUA8738184", @stop_sequence="0", @stop_headsign="", @pickup_type="0", @drop_off_type="1">
##<GTFS::Calendar:0x007fc1a22702e8 @service_id="11752", @monday="1", @tuesday="1", @wednesday="1", @thursday="1", @friday="1",
#@saturday="0", @sunday="0", @start_date="20150715", @end_date="20150731">
    #@routes.each do |r|
    #  puts r.inspect
    #  @trips.select { |t| t.route_id == r.id }.each do |t|
    #    puts t.inspect
    #    @stop_times.select { |st| st.trip_id = t.id }.each do |st|
    #      puts st.inspect
    #      cals = @calendars.select { |c| c.service_id == t.service_id }
    #      cals.each do |c|
    ##        puts c.inspect
    #        os = OpenStruct.new
    #        os.ligne = r.short_name
    #        os.route = r.long_name
    #        os.mission = t.headsign
    #        os.stop_point = 
    #        os.stop_id = st.stop_id
    #        os.num = extract_num(t.id)
    #        start_date = Date.parse(c.start_date)
    #        end_date   = Date.parse(c.end_date)
    #        (start_date..end_date).to_a.each do |date|
    #          next unless '1' == c.send(DAYS[date.wday])
    #          travel = os.dup
    #          travel.theorically_enter_at = extract_date(date, st.arrival_time)
    #          travel.date_str = date.strftime('%Y%m%d')
    #          #travel.exit_at = extract_date(date, st.departure_time)
    #          puts "travel h: #{travel.to_h.inspect}"
    #          tr = Travel.where(stop_point: travel.stop_point, date_str: travel.date_str, num: travel.num).first
    #          if tr
    #            tr.update_attributes!(travel.to_h)
    #          else
    #            Travel.create!(travel.to_h)
    #          end
    #        end
    #      end
    #    end
    #  end
    #end
    
    puts "Building Travels…"
    @stop_times.each do |st|
      trip  = @trips.find { |t| t.id == st.trip_id }
      route = @routes.find { |r| r.id == trip.route_id }
      os = OpenStruct.new
      os.ligne = route.short_name
      os.route = route.long_name
      os.mission = trip.headsign
      os.stop_id = st.stop_id
      os.num = extract_num(trip.id)
      #start_date = Date.parse(c.start_date)
      #end_date   = Date.parse(c.end_date)
      puts trip.service_id
      Array(@service_by_dates[trip.service_id]).each do |date_str|
        os.date_str = date_str
        os.theorically_enter_at = extract_date(Date.parse(date_str), st.arrival_time)
        trv  = os.to_h
        travel = Travel.where(stop_id: trv[:stop_id], date_str: trv[:date_str], num: trv[:num]).first
        if travel
          puts "ALREADY written"
        else
          Travel.create(trv)
          puts "Ok"
        end
      end
    end



    puts "OK!"
    puts
    puts
    puts GC.stat

    puts travels.inspect
    puts travels.length

  end
end
