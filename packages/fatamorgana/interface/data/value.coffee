FM = FataMorgana

class FM.Interface.Data.Value
  constructor: (options) ->
    # We want to create an internal field that we'll depend upon to isolate reactivity.
    oldValue = null
    field = new ReactiveField null

    updateAutorun = Tracker.autorun (computation) =>
      value = options.load()
      return if EJSON.equals value, oldValue

      # We store a copy of the current field so that if the source object
      # gets modified, we have the original value to compare equality to.
      oldValue = _.cloneDeep value

      field value

    value = (value) ->
      if value isnt undefined
        # Do we even need to do any change?
        valueChanged = not EJSON.equals value, oldValue

        options.save options.address, value if valueChanged
  
        return

      field()

    value.stop = ->
      updateAutorun.stop()

    # Return the state getter function (return must be explicit).
    return value
