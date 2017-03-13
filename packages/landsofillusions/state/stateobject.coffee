AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.StateObject
  constructor: (options) ->
    stateFields = {}

    fieldGetter = (fieldName, getterOptions = {}) ->
      # We want to create a new internal state field that we'll depend upon to isolate reactivity.
      unless stateFields[fieldName]
        stateFields[fieldName] = new LOI.StateField _.extend getterOptions,
          address: options.address.child fieldName

      stateFields[fieldName]

    # We want the state node to behave as getter/setter to which we pass a field name and new value.
    stateObject = (classOrFieldName, value) ->
      fieldName = _.thingId classOrFieldName

      unless fieldName
        # We didn't pass in a field so we're looking to get the whole state at this point. There's not much to do here
        # in terms of controlling reactivity, so we just return the value directly. Another reason of doing it this way
        # is that this returns an editable, actual game state. This is for example used from script nodes to write to
        # location state.
        return unless LOI.adventureInitialized()
        return _.nestedProperty LOI.adventure.gameState(), options.address.string()

      field = fieldGetter fieldName

      # Delegate to state field.
      field value

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf stateObject, @constructor.prototype

    stateObject.field = (fieldName, options) ->
      fieldGetter fieldName, options

    stateObject.clear = ->
      # Set this state node to an empty object.
      _.nestedProperty LOI.adventure.gameState(), options.address.string(), {}
      LOI.adventure.gameState.updated()

    # Sets the whole state object.
    stateObject.set = (newState) ->
      _.nestedProperty LOI.adventure.gameState(), options.address.string(), newState
      LOI.adventure.gameState.updated()

    stateObject.destroy = ->
      field.stop() for name, field of stateFields

    # Return the state getter function (return must be explicit).
    return stateObject
