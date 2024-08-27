unchangedObject = {}

_.mixin
  # Returns a property, either defined as a direct value or a function.
  # Note: we couldn't have just passed the target property directly
  # to be invoked as it wouldn't be bound to correct this.
  propertyValue: (target, propertyName) ->
    return target[propertyName]() if _.isFunction target[propertyName]

    target[propertyName]

  # Calculates the fields that need to be added or removed (signified by undefined) to go from a to b.
  objectDifference: (a, b) ->
    if _.isObject(a) and _.isObject(b)
      # For objects, we do a deep difference. If no field was changed, we return a special unchanged object.
      difference = {}
      changed = false
  
      for key, valueA of a
        valueDifference = _.objectDifference valueA, b[key]
        unless valueDifference is unchangedObject
          difference[key] = valueDifference
          changed = true
          
      for key, valueB of b when a[key] is undefined and valueB isnt undefined
        difference[key] = valueB
        changed = true
  
      if changed then difference else unchangedObject
      
    else if _.isArray(a) and _.isArray(b)
      # For arrays, we return an array as long as the target. Undefined fields in it signify no change.
      arrayDifference = []
  
      for i in [0...valueB.length]
        valueDifference = _.objectDifference a[i], b[i]
        unless valueDifference is unchangedObject
          arrayDifference[i] = valueDifference
          changed = true
  
      if changed then arrayDifference else unchangedObject

    else
      # Other value types can be compared directly.
      # Note: We want to use EJSON.equals instead of comparing a to b directly since EJSON.equals equates NaN to true.
      # Note: We want to return the clone of b so we get a completely new
      # version in case we're setting a reference type that might change later.
      if EJSON.equals a, b then unchangedObject else EJSON.clone b
      
  # Changes source to get the values from difference (or remove them where undefined).
  applyObjectDifference: (source, difference) ->
    if _.isObject(source) and _.isObject(difference)
      for key, differenceValue of difference
        if differenceValue is undefined
          delete source[key]
      
        else
          source[key] = _.applyObjectDifference source[key], differenceValue
  
      source
      
    else if _.isArray(source) and _.isArray(difference)
      source.length = difference.length
      
      for i in [0...source.length] when difference[i] isnt undefined
        source[i] = _.applyObjectDifference source[i], difference[i]
  
      source
    
    else
      # Note: To allow for the difference object to be changing, we need to return a fresh copy of reference types.
      EJSON.clone difference

  # Calculates if object a contains all values set in b.
  objectContains: (a, b) ->
    if _.isObject(a) and _.isObject(b)
      for key, valueB of b
        return false unless _.objectContains a[key], valueB
        
      true
      
    else if _.isArray(a) and _.isArray(b)
      for i in [0...valueB.length]
        return false unless _.objectContains a[i], b[i]
        
      true

    else
      # Note: We want to use EJSON.equals instead of comparing a to b directly since EJSON.equals equates NaN to true.
      EJSON.equals a, b
    
  # Override existing values of a with values from b. This mutates a.
  override: (a, b) ->
    return a unless b?
    
    for key of a when b[key]?
      a[key] = b[key]
      
    a
  
  overrideDeep: (a, b) ->
    return a unless b?

    for key, value of a when b[key]?
      if _.isObject(value)
        _.overrideDeep value, b[key]
        
      else
        a[key] = b[key]
      
    a
