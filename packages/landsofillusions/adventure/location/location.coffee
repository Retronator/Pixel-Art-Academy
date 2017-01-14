AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Location extends LOI.Adventure.Thing
  # Static location properties and methods

  # Urls of scripts used at this location.
  @scriptUrls: -> []

  # The maximum height of location's illustration. By default there is no illustration (height 0).
  @illustrationHeight: -> 0
  illustrationHeight: -> @constructor.illustrationHeight()

  @initialize: ->
    super

    # Add a visited field unique to this location class.
    @visited = new ReactiveField false

  # Location instance

  constructor: (@options) ->
    super

    @thingInstances = new LOI.StateInstances
      state: => @things()
      location: @

    # Subscribe to translations of exit locations' avatars so we get their names.
    @exitsTranslationSubscriptions = new ComputedField =>
      subscriptions = {}
      for directionKey, locationClass of @exits()
        locationId = _.thingId locationClass
        subscriptions[locationId] = AB.subscribeNamespace "#{locationId}.Avatar"

      subscriptions

  destroy: ->
    super

    @exitsTranslationSubscriptions.stop()

  ready: ->
    conditions = _.flattenDeep [
      super
      @thingInstances.ready()
      subscription.ready() for locationId, subscription of @exitsTranslationSubscriptions()
    ]

    ready = _.every conditions

    console.log "%cLocation #{@constructor.id()} ready?", 'background: LightSkyBlue', ready, conditions if LOI.debug

    ready

  exits: -> {} # Override to provide location exits in {direction: location class} format

  things: -> [] # Override to provide an array of thing classes at this location.
