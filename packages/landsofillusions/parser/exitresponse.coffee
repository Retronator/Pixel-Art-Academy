AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

# Exit response captures the listener's response for the attempt to exit a location.
class LOI.Parser.ExitResponse
  constructor: (@options) ->
    @currentLocationClass = @options.currentLocationClass
    @destinationLocationClass = @options.destinationLocationClass

    @_exitPrevented = false

  # Call to indicate that exit should not be allowed.
  preventExit: ->
    @_exitPrevented = true

  wasExitPrevented: ->
    @_exitPrevented
