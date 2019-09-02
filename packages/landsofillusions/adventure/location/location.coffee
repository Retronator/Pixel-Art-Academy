AB = Artificial.Babel
AM = Artificial.Mirage
AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Adventure.Location extends LOI.Adventure.Scene
  # Static location properties and methods

  # Override for Scene location.
  @location: -> @

  # The region this location belongs to.
  @region: -> throw new AE.NotImplementedException "You must specify region class."
  region: -> @constructor.region()

  @isPrivate: -> false # Override if other people shouldn't show up at this location.

  @illustration: ->
    # Override to provide information about the illustration (name, height)
    # for this context. By default there is no illustration.
    null
  
  illustration: -> @constructor.illustration()

  @initialize: ->
    super arguments...

    # Add a visited field unique to this location class.
    @visited = new ReactiveField false

  exits: -> # Override to provide location exits in {direction: location class} format
