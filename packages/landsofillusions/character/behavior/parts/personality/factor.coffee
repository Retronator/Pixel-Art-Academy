LOI = LandsOfIllusions

class LOI.Character.Behavior.Personality.Factor extends LOI.Character.Part
  constructor: (@options) ->
    super arguments...

  traitsString: ->
    @properties.traits.toString()

  toString: ->
    @traitsString()
