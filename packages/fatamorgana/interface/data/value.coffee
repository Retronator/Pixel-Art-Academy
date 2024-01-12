FM = FataMorgana

class FM.Interface.Data.Value
  constructor: (options) ->
    # We want to create an internal field that we'll depend upon to isolate reactivity.
    oldValue = null
    field = new ReactiveField null

    update = (value) ->
      return if EJSON.equals value, oldValue

      # We store a copy of the current field so that if the source object
      # gets modified, we have the original value to compare equality to.
      oldValue = _.cloneDeep value

      field value
      
    updateAutorun = Tracker.autorun (computation) ->
      update options.load()

    value = (value) ->
      if value isnt undefined
        # Do we even need to do any change?
        valueChanged = not EJSON.equals value, oldValue
        
        if valueChanged
          options.save options.address, value
          
          # Don't wait for old value to update from the autorun, so we can
          # detect changes when multiple sets are done within the same computation.
          update value
  
        return value

      field()

    value.stop = ->
      updateAutorun.stop()

    # Return the state getter function (return must be explicit).
    return value
