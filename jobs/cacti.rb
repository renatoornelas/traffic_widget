require "./lib/cacti"

q = Cacti.new "stat.cityshop.com.br"

traffic_graphs = []
traffic_graphs << { :data_handler => "traffic",   :graph_id => 482  }
traffic_graphs << { :data_handler => "traffic2",  :graph_id => 492  }
traffic_graphs << { :data_handler => "traffic3",  :graph_id => 1045 }
traffic_graphs << { :data_handler => "traffic4",  :graph_id => 850  }
traffic_graphs << { :data_handler => "traffic5",  :graph_id => 1171 }
traffic_graphs << { :data_handler => "traffic6",  :graph_id => 801  }
traffic_graphs << { :data_handler => "traffic7",  :graph_id => 1083 }
traffic_graphs << { :data_handler => "traffic8",  :graph_id => 481  }
traffic_graphs << { :data_handler => "traffic9",  :graph_id => 1052, :inbound_ds => 'Total IN ', :outbound_ds => 'Total OUT' }
traffic_graphs << { :data_handler => "traffic10", :graph_id => 1052, :inbound_ds => 'Total IN ', :outbound_ds => 'Total OUT', :graph_start => 43200 }
traffic_graphs << { :data_handler => "traffic11", :graph_id => 1052, :inbound_ds => 'Total IN ', :outbound_ds => 'Total OUT', :graph_start => 86400 }
traffic_graphs << { :data_handler => "traffic12", :graph_id => 1052, :inbound_ds => 'Total IN ', :outbound_ds => 'Total OUT', :graph_start => 43200 }


# last started parkingsessions
SCHEDULER.every '60s', :first_in => 30 do
    # Create an instance of our helper class
    traffic_graphs.each do |graph|
      
      inbound_ds = graph[:inbound_ds] || "IN "
      outbound_ds = graph[:outbound_ds] || "OUT"
      graph_start = graph[:graph_start] || 43200
      
      
      points_in = q.points graph[:graph_id], inbound_ds, Time.new.to_i-graph_start
      points_out = q.points graph[:graph_id], outbound_ds, Time.new.to_i-graph_start
   
      title = q.title graph[:graph_id]
     
      # send to dashboard, so the number the meter and the graph widget can understand it
      if graph[:data_handler] == "traffic12"

        traffic_data = [
          {
            name: "Upload",
            data: points_out,
          },
          {
            name: "Download",
            data: points_in,
          },
        ]
        send_event graph[:data_handler], { series: traffic_data, title: title }
      else 
        send_event graph[:data_handler], { points_in: points_in, points_out: points_out, title: title }
      end
    end
    

end
