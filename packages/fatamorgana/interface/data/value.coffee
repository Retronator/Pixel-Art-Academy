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

    # We store a copy of the current field so that if the source object
    # gets modified, we have the original value to compare equality to.
    oldValue = new ComputedField =>
      _.clone field()
    ,
      true

    value = (value) ->
      if value isnt undefined
        # Do we even need to do any change?
        valueChanged = not EJSON.equals value, oldValue()

        options.save options.address, value if valueChanged
  
        return

      field()

    value.stop = ->
      field.stop()
      oldValue.stop()

    # Return the state getter function (return must be explicit).
    return value
