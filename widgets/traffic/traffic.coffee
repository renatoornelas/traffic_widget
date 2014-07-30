class Dashing.Traffic extends Dashing.Widget

  @accessor 'current_in', ->
    series = @get('series')
    if series 
      series[0][series[0].length - 1].y

  @accessor 'current_out', ->
    series = @get('series')
    if series 
      series[1][series[1].length - 1].y


  ready: ->
    container = $(@node).parent()
    # Gross hacks. Let's fix this.
    width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
    height = (Dashing.widget_base_dimensions[1] * container.data("sizey")) + Dashing.widget_margins[1] * 2 * (container.data("sizey") - 1)-10 # -10 p/ sobrar espaco p/ o titulo
    data_series = @get('series') if @get('series')
    
    @traffic = new Rickshaw.Graph(
      element: @node
      width: width
      height: height
      stroke: true
      stack: false
      series: [
        {
        color: "SeaGreen",
        data: data_series[0]
        name: "Download"
        },
        {
        color: "steelblue",
        data: data_series[1]
        name: "Upload"
        }
      ]
    )

    time = new Rickshaw.Fixtures.Time.Local()
    time_unit = time.unit('6-hour')
    tick_fmt = (x) -> return ""
    
    x_axis = new Rickshaw.Graph.Axis.X(graph: @traffic, tickFormat: tick_fmt, ticks: 8)
    
    x_axis = new Rickshaw.Graph.Axis.Time(graph: @traffic, timeUnit: time_unit, timeFixture: time, tickValues: time_unit)
    
    y_axis = new Rickshaw.Graph.Axis.Y(graph: @traffic, tickFormat: Rickshaw.Fixtures.Number.formatKMBT, ticks: 5)

    @traffic.renderer.unstack = true;
    @traffic.render()

  onData: (data) ->
    if @traffic 
      @traffic.series[0].data = data.series[0]
      @traffic.series[1].data = data.series[1]
      @traffic.render()
    
