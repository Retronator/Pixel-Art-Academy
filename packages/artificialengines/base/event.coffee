AB = Artificial.Base
AE = Artificial.Everywhere

class AB.Event
  constructor: ->
    _handlers = []
    
    # We want Event to behave as a function that calls the handlers.
    event = -> handler.callback.apply handler.listener, arguments for handler in _handlers
  
    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf event, @constructor.prototype
    
    event.addHandler = (listener, callback) ->
      _handlers.push {listener, callback}
  
    event.removeHandler = (listener, callback) ->
      _.remove _handlers, (handler) => handler.listener is listener and handler.callback is callback
  
    event.removeHandlers = (listener) ->
      _.remove _handlers, (handler) => handler.listener is listener
      
    # Return the event function (return must be explicit).
    return event
