LOI = LandsOfIllusions

class LOI.Adventure.Situation.Circumstance
  @Types:
    Array: 'Array'
    Map: 'Map'

  constructor: (type) ->
    value = null
    
    circumstance = ->
      value

    circumstance.first = ->
      _.first value

    circumstance.last = ->
      _.last value

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf circumstance, @constructor.prototype

    prepareArray = (newValue) ->
      newValue = [newValue] unless _.isArray newValue

      # Remove any undefined and null values.
      newValue = _.without newValue, null, undefined

      newValue

    circumstance.add = (newValue) ->
      switch type
        when @constructor.Types.Array
          newValue = prepareArray newValue
          value = _.union value, newValue

        when @constructor.Types.Map
          _.extend value, newValue

    circumstance.remove = (newValue) ->
      switch type
        when @constructor.Types.Array
          newValue = prepareArray newValue
          value = _.filter value, (member) =>
            # Don't include members that are in the remove set.
            return false if member in newValue

            # Also don't include members that are instances of classes in the remove set.
            for newMember in newValue
              return false if member instanceof newMember

            true

        when @constructor.Types.Map
          delete value[property] for property of newValue

    circumstance.clear = ->
      switch type
        when @constructor.Types.Array then value = []
        when @constructor.Types.Map then value = {}

    circumstance.override = (newValue) ->
      circumstance.clear()
      circumstance.add newValue

    # Clear to start value.
    circumstance.clear()

    # Return the circumstance getter function (return must be explicit).
    return circumstance
