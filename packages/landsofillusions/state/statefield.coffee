AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.StateField
  constructor: (options) ->
    options.stateType ?= LOI.GameState.Type.Editable
    
    # We want to create an internal computed field that we'll depend upon to isolate reactivity.
    field = new ComputedField =>
      return unless LOI.adventureInitialized()

      value = _.nestedProperty LOI.adventure[options.stateType](), options.address.string()

      # If we didn't find the value, see if we have a default value set.
      value ?= options.default

      # Return the final value.
      value
    ,
      true

    # We want the state field to behave as a getter/setter.
    stateField = (value) ->
      # Is this a setter? We compare to undefined and not just use
      # value? since we want to be able to set the value null to the field.
      if value isnt undefined
        # Do we even need to do any change?
        oldValue = field()

        # We need to rewrite the field if the value changed (and with objects
        # we never know if they were internally changed, so we do it always).
        if value isnt oldValue or _.isObject(value)
          # We directly change the value of the field and trigger state update.
          _.nestedProperty LOI.adventure[options.stateType](), options.address.string(), value
          LOI.adventure[options.stateType].updated()

        return

      # No, this is a getter, so just return the value from the computed field.
      field()

    stateField.stop = ->
      field.stop()

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf stateField, @constructor.prototype

    # Return the state getter function (return must be explicit).
    return stateField
