require 'gtfs'
class GtfsToTravels
  include Sidekiq::Worker

  GTFS_URL = 'https://ressources.data.sncf.com/api/datasets/1.0/sncf-transilien-gtfs/attachments/export_tn_gtfs_last_zip/'

  ALL_KNOWN_SHORT_NAMES = %w(A B C D E H J K L N P R T4 U)

  def perform(short_names: ALL_KNOWN_SHORT_NAMES)
    raise ArgumentError, "short_names: named arg SHOULD be an Array of String" unless short_name.is_a?(Array)
    puts "Loading GTFS: #{GTFS_URL}"
    @source = GTFS::Source.build(GTFS_URL)
    puts "Loading done."

    @routes = @source.routes.select { |r| short_names.include?(r.short_name) }
    route_ids = @routes.map(&:id)
    @trips = @source.trips.select { |t| route_ids.include?(t.route_id) }
    trip_ids = @trips.map(&:id)
    @stop_times = @source.stop_times.select { |st| trip_ids.include?(st.trip_id) }
  end
end
