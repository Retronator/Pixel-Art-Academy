AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.StateField
  constructor: (options) ->
    options.stateType ?= LOI.GameState.Type.Editable

    # Support for lazy updates (value changes that don't trigger whole state reactivity, but just the field's.
    lazyValueUpdated = new Tracker.Dependency()

    # We want to create an internal computed field that we'll depend upon to isolate reactivity.
    field = new ComputedField =>
      return unless LOI.adventureInitialized()

      # Update also on lazy updates.
      lazyValueUpdated.depend()

      value = _.nestedProperty LOI.adventure[options.stateType](), options.address.string()

      # If we didn't find the value, see if we have a default value set.
      value ?= options.default

      # Return the final value.
      value
    ,
      true
    ,
      options.equalityFunction

    # We want the state field to behave as a getter/setter.
    stateField = (value) ->
      # Is this a setter? We compare to undefined and not just use
      # value? since we want to be able to set the value null to the field.
      if value isnt undefined
        # Do we even need to do any change?
        oldValue = field()

        # We need to rewrite the field if the value changed.
        if options.equalityFunction
          # Delegate to the equality function to do the comparison.
          valueChanged = not options.equalityFunction value, oldValue
          
        else
          # With objects we never know if they were internally changed, so we do it always)
          valueChanged = value isnt oldValue or _.isObject(value)

        if valueChanged
          # We directly change the value of the field and trigger state update.
          return unless state = LOI.adventure[options.stateType]()
          _.nestedProperty state, options.address.string(), value

          # We trigger reactive state changes, unless the updates are lazy.
          if options.lazyUpdates
            lazyValueUpdated.changed()

          else
            LOI.adventure[options.stateType].updated()

        return

      # No, this is a getter, so just return the value from the computed field.
      field()

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf stateField, @constructor.prototype

    stateField.address = options.address

    stateField.stop = ->
      field.stop()

    # Return the state getter function (return must be explicit).
    return stateField
