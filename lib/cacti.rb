require "net/https"
require "uri"
require "json"
require "date"

class Cacti
    attr_reader :uri, :data_sources, :graph_data
    # Pass in the url to where you cacti instance is hosted
    def initialize(url, graph_id, data_sources=["IN ", "OUT"], graph_start=nil, graph_end=nil)
        @uri = URI.parse(url)
        @graph_id = graph_id
        @data_sources = data_sources
 
        graph_start ||= Time.new.to_i - 86400;
        
        @graph_data = query graph_id, graph_start, graph_end
    end

    # This is the raw query method, it will fetch the 
    # JSON from the Graphite and parse it
    def query(graph_id, graph_start=nil, graph_end=nil)
        graph_start ||= Time.new.to_i - 86400;
        
        http     = Net::HTTP.new (@uri.host)
        
        http.use_ssl = (@uri.port == 443)
        
        request  = http.request Net::HTTP::Get.new("#{@uri.request_uri}?local_graph_id=#{graph_id}&rra_id=0&view_type=&graph_start=#{graph_start}&graph_end=#{graph_end}")

        result = JSON.parse(request.body, :symbolize_names => true, :allow_nan => true)
        return result
    end
    
    def get_value(datapoint,index)
        value = datapoint[index] || 0
        return value.round(2)
    end
    
    # This is high-level function that will fetch a set of datapoints
    # since the given start point and convert it into a format that the
    # graph widget of Dashing can understand
    def points(data_source)
        datapoints = @graph_data[:data]

        index = @graph_data[:meta][:legend].find_index(data_source)
        points = []

        (datapoints.select { |el| not el[0].nil? }).each do|item|
            time = get_value(item,0).to_i
            points << { x: time, y: get_value(item,index)}
        end

        return points
    end
    
    def series
      series = []
      @data_sources.each do |ds|
        series << points(ds)
      end
      return series
    end

    # Not all Dashing widgets need a set of points, often just 
    # the current value is enough. This method does just that, it fetches
    # the value for last point-in-time and returns it
    def value(data_source)
        
        index = @graph_data[:meta][:legend].find_index(data_source)
        
        last = (@graph_data[:data].select { |el| not el[0].nil? }).last
        return get_value(last,index)
    end
    
    def values
      values = []
      @data_sources.each do |ds|
        values << value(ds)
      end
      return values
    end
      
    def title
        title = @graph_data[:meta][:title]
    end
    
end
