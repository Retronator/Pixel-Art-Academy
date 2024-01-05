AMe = Artificial.Melody

class AMe.Section
  constructor: (@composition, options) ->
    _.defaults @, options,
      duration: 0
      events: []
      transitions: []
    
  schedule: (time, output) -> @_schedule @events, time, output
  
  _schedule: (events, time, output) ->
    eventHandles = (event.schedule time, output for event in events)
    
    new AMe.SectionHandle @, =>
      event.stop() for event in eventHandles
