require "./lib/cacti"

city10 = "http://stat.cityshop.com.br"
openx = "https://cacti.openx.com.br"

traffic_graphs = []
traffic_graphs << { :cacti => city10, :data_handler => "traffic1",   :graph_id => 482  }
traffic_graphs << { :cacti => city10, :data_handler => "traffic2",  :graph_id => 492  }
#traffic_graphs << { :cacti => city10, :data_handler => "traffic3",  :graph_id => 1045 }
#traffic_graphs << { :cacti => city10, :data_handler => "traffic4",  :graph_id => 850  }
#traffic_graphs << { :cacti => city10, :data_handler => "traffic5",  :graph_id => 1171 }
#traffic_graphs << { :cacti => city10, :data_handler => "traffic6",  :graph_id => 801  }
#traffic_graphs << { :cacti => city10, :data_handler => "traffic7",  :graph_id => 1083 }
#traffic_graphs << { :cacti => city10, :data_handler => "traffic8",  :graph_id => 481  }
#traffic_graphs << { :cacti => city10, :data_handler => "traffic9",  :graph_id => 1052, :ds => ['Total IN ', 'Total OUT'] }
#traffic_graphs << { :cacti => city10, :data_handler => "traffic10", :graph_id => 1052, :ds => ['Total IN ', 'Total OUT'], :start => 43200 }
#traffic_graphs << { :cacti => city10, :data_handler => "traffic11", :graph_id => 1052, :ds => ['Total IN ', 'Total OUT'], :start => 86400 }
#traffic_graphs << { :cacti => openx, :data_handler => "traffic12", :graph_id => 206 }

#puts Sinatra::Application.inspect

# last started parkingsessions
SCHEDULER.every '30s', :first_in => 0 do

#  puts result['graph'].inspect
  
  traffic_graphs.each do |graph|

    # Look if we need to change something due to API calls
    # Like this: curl -d '{ "auth_token": "FNX9qNaeUTXDwMbaw2TEggJTcT8UNmkK", "params": {"start": 7200, "cacti": "https://cacti.openx.com.br", "graph_id": 206 }}' http://localhost:3030/widgets/traffic2

    history = JSON.parse(Sinatra::Application.settings.history[graph[:data_handler]].sub("data: ", ""))
    if (history['params'])

      history['params'].each do |param|
        puts param.inspect
        graph[param[0].to_sym] = param[1]
      end
      puts graph.inspect
    end
    
    start = graph[:start] || 43200

    q = Cacti.new graph[:cacti], graph[:graph_id], :data_sources => graph[:ds], :graph_start => start
 
    send_event graph[:data_handler], { series: q.series, title: q.title }
  end
  


end

