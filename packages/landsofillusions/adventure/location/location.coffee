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

  # The maximum height of location's illustration. By default there is no illustration (height 0).
  @illustrationHeight: -> 0
  illustrationHeight: -> @constructor.illustrationHeight()

  @initialize: ->
    super

    # Add a visited field unique to this location class.
    @visited = new ReactiveField false

  # Location instance
  constructor: (@options = {}) ->
    # Scene expects options so make sure we aren't passing null (locations that
    # inherit from this and override the constructor without options would do that).
    super @options

  exits: -> # Override to provide location exits in {direction: location class} format

  isPrivate: -> false # Override if other people shouldn't show up at this location.
