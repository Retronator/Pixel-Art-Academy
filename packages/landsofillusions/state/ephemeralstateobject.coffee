AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.EphemeralStateObject
  constructor: (options) ->
    state = new ReactiveField {}
    fieldGetters = {}

    fieldGetter = (fieldName) ->
      # We want to create a new internal state field that we'll depend upon to isolate reactivity.
      unless fieldGetters[fieldName]
        field = new ComputedField =>
          currentState = state()
          currentState[fieldName]
        ,
          true

        fieldGetters[fieldName] = (value) =>
          if value isnt undefined
            currentState = state()
            currentState[fieldName] = value
            Tracker.nonreactive =>
              state currentState

          field()

        fieldGetters[fieldName].stop = =>
          field.stop()

      fieldGetters[fieldName]

    # We want the state node to behave as getter/setter to which we pass a field name and new value.
    ephemeralStateObject = (classOrFieldName, value) ->
      fieldName = _.thingId classOrFieldName

      unless fieldName
        # We didn't pass in a field so we're looking to get the whole state at this point. There's not much to do here
        # in terms of controlling reactivity, so we just return the value directly. Another reason of doing it this way
        # is that this returns an editable, actual game state. This is for example used from script nodes to write to
        # ephemeral state.
        return state()

      field = fieldGetter fieldName

      # Delegate to state field.
      field value

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf ephemeralStateObject, @constructor.prototype

    ephemeralStateObject.field = (fieldName) ->
      # Are we asking for a specific field, or the whole state field?
      if fieldName
        fieldGetter fieldName

      else
        state

    # Set this state node to an empty object.
    ephemeralStateObject.clear = ->
      state {}

    # Sets the whole state object.
    ephemeralStateObject.set = (newState) ->
      state newState

    ephemeralStateObject.destroy = ->
      field.stop() for name, field of fieldGetters

    # Return the state getter function (return must be explicit).
    return ephemeralStateObject
