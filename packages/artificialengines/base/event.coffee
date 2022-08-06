AB = Artificial.Base
AE = Artificial.Everywhere

class AB.Event
  constructor: ->
    _handlers = []
    
    # We want Event to behave as a function that calls the handlers.
    event = -> handler arguments... for handler in _handlers
  
    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf event, @constructor.prototype
    
    event.addHandler = (handler) ->
      _handlers.push handler
  
    event.removeHandler = (handler) ->
      handlerIndex = _handlers.indexOf handler
    
      throw new AE.ArgumentException "Provided handler is not handling this event." if handlerIndex is -1
    
      _handlers.splice handlerIndex, 1
  
    # Return the event function (return must be explicit).
    return event
