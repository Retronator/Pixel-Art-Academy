FM = FataMorgana

class FM.Interface.Data.Value
  constructor: (options) ->
    # We want to create an internal computed field that we'll depend upon to isolate reactivity.
    field = new ComputedField =>
      _.nestedProperty options.load(), options.address
    ,
      true
    ,
      EJSON.equals

    value = (value) ->
      if value isnt undefined
        # Do we even need to do any change?
        oldValue = field()
        valueChanged = not EJSON.equals value, oldValue
  
        options.save options.address, value if valueChanged
  
        return

      field()

    value.stop = ->
      field.stop()

    # Return the state getter function (return must be explicit).
    return value
