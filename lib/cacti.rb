require "net/http"
require "JSON"
require "date"

class Cacti
    attr_reader :url, :port
    # Pass in the url to where you cacti instance is hosted
    def initialize(url, port = 80)
        @url = url
        @port = port
    end

    def get_value(datapoint,index)
        value = datapoint[index] || 0
        return value.round(2)
    end
    
    # This is the raw query method, it will fetch the 
    # JSON from the Graphite and parse it
    def query(graph_id, graph_start=nil, graph_end=nil)
        graph_start ||= Time.new.to_i - 86400;
        #graph_end ||= Time.new.to_i;
        
        http     = Net::HTTP.new "#{@url}"
        
        request  = http.request Net::HTTP::Get.new("/graph_json.php?local_graph_id=#{graph_id}&rra_id=0&view_type=&graph_start=#{graph_start}&graph_end=#{graph_end}")

        result = JSON.parse(request.body, :symbolize_names => true, :allow_nan => true)

        return result
    end

    # This is high-level function that will fetch a set of datapoints
    # since the given start point and convert it into a format that the
    # graph widget of Dashing can understand
    def points(graph_id, data_source, graph_start=nil, graph_end=nil)
        stats = query graph_id, graph_start, graph_end
        datapoints = stats[:data]

        index = stats[:meta][:legend].find_index(data_source)
        points = []

        (datapoints.select { |el| not el[0].nil? }).each do|item|
            time = get_value(item,0).to_i
            points << { x: time, y: get_value(item,index)}
        end

        return points
    end

    # Not all Dashing widgets need a set of points, often just 
    # the current value is enough. This method does just that, it fetches
    # the value for last point-in-time and returns it
    def value(graph_id, data_source, graph_start=nil, graph_end=nil)
        stats = query graph_id, graph_start, graph_end
        
        index = stats[:meta][:legend].find_index(data_source)
        
        last = (stats[:data].select { |el| not el[0].nil? }).last
        
        return get_value(last,index)
    end
    
    def title(graph_id)
        stats = query graph_id
        title = stats[:meta][:title]
        return title
    end
    
end
