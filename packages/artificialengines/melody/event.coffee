AE = Artificial.Everywhere
AMe = Artificial.Melody

class AMe.Event
  constructor: (@audioManager, options) ->
    _.defaults @, options,
      time: 0
  
  destroy: -> # Overload to clean up any resources.
  
  ready: -> true # Overload if the event creates any resources that aren't immediately available.

  schedule: (sectionStartTime, output) ->
    console.log "Scheduling melody event", @ if AMe.debug
    # Extend and return an event handle that represents the scheduled event.
