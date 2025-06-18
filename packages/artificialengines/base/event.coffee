AB = Artificial.Base
AE = Artificial.Everywhere

class AB.Event
  @debug = false
  
  constructor: (parent) ->
    _handlers = []
    
    # We want Event to behave as a function that calls the handlers.
    event = -> handler.callback.apply handler.listener, arguments for handler in _handlers
  
    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf event, @constructor.prototype
    
    event.parent = parent
    
    event.addHandler = (listener, callback) ->
      console.log "%cAdding event handler to", 'background:PaleGreen; color:Black;', parent, "for", listener, "with", callback if AB.Event.debug
      _handlers.push {listener, callback}
  
    event.removeHandler = (listener, callback) ->
      console.log "%cRemoving event handler from", 'background:LightCoral; color:Black;', parent, "for", listener, "with", callback if AB.Event.debug
      _.remove _handlers, (handler) => handler.listener is listener and handler.callback is callback
  
    event.removeHandlers = (listener) ->
      console.log "%cRemoving all event handlers from", 'background:LightCoral; color:Black;', parent, "for", listener if AB.Event.debug
      _.remove _handlers, (handler) => handler.listener is listener
      
    # Return the event function (return must be explicit).
    return event
