AMe = Artificial.Melody

class AMe.Section
  constructor: (@composition, options) ->
    _.defaults @, options,
      duration: 0
      events: []
      transitionOutEvents: []
      transitions: []
  
  destroy: ->
    event.destroy() for event in @events
    event.destroy() for event in @transitionOutEvents
    
  ready: ->
    conditions = (event.ready() for event in [@events..., @transitionOutEvents...])
    _.every conditions
    
  schedule: (time, output) -> @_schedule @events, time, output
  scheduleTransitionOut: (time, output) -> @_schedule @transitionOutEvents, time, output
  
  _schedule: (events, time, output) ->
    eventHandles = (event.schedule time, output for event in events)
    
    new AMe.SectionHandle @, =>
      event.stop() for event in eventHandles
