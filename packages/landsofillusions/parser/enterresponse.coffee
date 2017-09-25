AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

# Exit response captures the listener's response for the attempt to exit a location.
class LOI.Parser.EnterResponse
  constructor: (@options) ->
    @currentLocationClass = @options.currentLocationClass

    @_introductionFunction = null

  # Call to indicate that exit should not be allowed.
  overrideIntroduction: (introductionFunction) ->
    @_introductionFunction = introductionFunction
    
  introductionFunction: ->
    @_introductionFunction
