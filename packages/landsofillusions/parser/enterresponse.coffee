AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

# Exit response captures the listener's response for the attempt to exit a location.
class LOI.Parser.EnterResponse
  constructor: (@options) ->
    @currentLocationClass = @options.currentLocationClass

    @_introductionFunction = null

  # Use to provide a different introduction text to the scene. You can
  # use the intro static method of a scene to automatically do this.
  overrideIntroduction: (introductionFunction) ->
    @_introductionFunction = introductionFunction
    
  introductionFunction: ->
    @_introductionFunction
