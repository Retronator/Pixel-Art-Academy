LOI = LandsOfIllusions

class LOI.Adventure.Scene extends LOI.Adventure.Thing
  @location: -> throw new AE.NotImplementedException
  location: -> @constructor.location()

  @fullName: -> "" # Scenes don't need to be named.

  constructor: (@options) ->
    super

    @section = @options.section

  things: -> [] # Override to provide a list of things that should be present at this location.
