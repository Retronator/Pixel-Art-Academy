# Calls the trigger function when the value function changes from one defined value to another.
Tracker.triggerOnDefinedChange = (valueFunction, triggerFunction) ->
  currentValue = valueFunction()
  
  autorunHandle = Tracker.autorun =>
    newValue = valueFunction()
    
    if currentValue isnt undefined and newValue isnt undefined and newValue isnt currentValue
      triggerFunction newValue
      
    currentValue = newValue

  # Return a persistent handle that wraps around and mimics the inner changing autorun handle.
  stop: =>
    autorunHandle?.stop()
