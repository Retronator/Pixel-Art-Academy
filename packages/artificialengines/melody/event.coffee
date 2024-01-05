AE = Artificial.Everywhere
AMe = Artificial.Melody

class AMe.Event
  constructor: (@section, options) ->
    _.defaults @, options,
      time: 0

  schedule: (sectionStartTime, output) ->
    console.log "Scheduling melody event", @ if AMe.debug
    # Extend and return an event handle that represents the scheduled event.
