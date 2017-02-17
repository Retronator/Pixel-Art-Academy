AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Location extends LOI.Adventure.Scene
  # Static location properties and methods

  # Override for Scene location.
  @location: -> @

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

  constructor: (@options = {}) ->
    super @options

    # Subscribe to translations of exit locations' avatars so we get their names.
    @exitAvatarsByLocationId = new ComputedField =>
      # Generate a unique set of exit classes from all directions (some directions might lead to
      # same location) so we don't have multiple avatar objects for the same location.
      exitClasses = _.uniq _.values @exits()
      exitClasses = _.without exitClasses, null

      avatarsById = {}
      avatarsById[exitClass.id()] = exitClass.createAvatar() for exitClass in exitClasses
      
      avatarsById

  destroy: ->
    super

    exitAvatarsByLocationId = @exitAvatarsByLocationId()
    @exitAvatarsByLocationId.stop()

    avatar.destroy() for locationId, avatar of exitAvatarsByLocationId

  ready: ->
    conditions = _.flattenDeep [
      super
      avatar.ready() for locationId, avatar of @exitAvatarsByLocationId()
    ]

    ready = _.every conditions

    console.log "%cLocation #{@constructor.id()} ready?", 'background: LightSkyBlue', ready, conditions if LOI.debug

    ready

  exits: -> {} # Override to provide location exits in {direction: location class} format

  things: -> [] # Override to provide an array of thing classes at this location.
