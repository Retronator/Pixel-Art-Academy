LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class Retronator.HQ.Scenes.Shelley extends LOI.Adventure.Scene
  @id: -> 'Retronator.HQ.Scenes.Shelley'

  @timelineId: -> PAA.TimelineIds.RealLife

  @initialize()

  @defaultScriptUrl: -> 'retronator_retronator-hq/scenes/shelley.script'

  @ActionTypes:
    Move: 'Move'
    Activity: 'Activity'

  constructor: ->
    super

    # Set starting location and start moving around.
    @autorun (computation) =>
      return unless LOI.adventure.gameState()
      computation.stop()

      @state 'currentLocation', HQ.GalleryEast.id() unless @state 'currentLocation'

      @_scheduleNextAction()

    @currentLocation = new ComputedField =>
      return unless currentLocationId = @currentLocationId()

      LOI.Adventure.Location.getClassForId currentLocationId

  destroy: ->
    super

    Meteor.clearTimeout @_nextMessageTimeout

  currentLocationId: ->
    @state 'currentLocation'

  location: ->
    # Shelley changes location.
    LOI.Adventure.Location.getClassForId @currentLocationId()

  things: ->
    things = []

    things.push PAA.Cast.Shelley if LOI.adventure.currentLocationId() is @currentLocationId()

    things

  _scheduleNextAction: (options = {}) ->
    # Make the next action in 30-60 seconds.
    options.delay ?= (1 + Math.random()) * 30 * 1000

    @_nextActionTimeout = Meteor.setTimeout =>
      # Don't do the action if the user is busy doing something.
      if LOI.adventure.interface.busy()
        # Retry in 10 seconds.
        @_scheduleNextAction delay: 10000
        return

      # Looks OK, do something!
      @_doAction()

      @_scheduleNextAction()
    ,
      options.delay

  _doAction: ->
    return unless location = @location()

    listener = @listeners[0]
    currentLocationId = @currentLocationId()
    playerLocationId = LOI.adventure.currentLocationId()

    lastAction = @state 'lastAction'

    if lastAction is @constructor.ActionTypes.Move or (not lastAction and Math.random() < 0.5)
      @state 'lastAction', @constructor.ActionTypes.Activity

      # Do an activity but only display it if we're at Shelley' location.
      return unless playerLocationId is currentLocationId

      switch location
        when HQ.GalleryEast then choices = ['Drinks']
        when HQ.GalleryWest then choices = ['Stare']
        when HQ.ArtStudio then choices = ['AhKids']
        when HQ.Store then choices = ['Melanija']
        else
          choices = []

      # Add choices that are always possible.
      choices = choices.concat ['Gold']

      label = Random.choice choices

      listener.startScript label: label

    else
      # Move.
      switch location
        when HQ.GalleryEast then choices = [HQ.GalleryWest]
        when HQ.GalleryWest then choices = [HQ.GalleryEast, HQ.ArtStudio, HQ.Store]
        when HQ.ArtStudio then choices = [HQ.GalleryWest]
        when HQ.Store then choices = [HQ.GalleryWest]

      nextLocationId = Random.choice(choices).id()

      listener.startScript label: 'Leave' if playerLocationId is currentLocationId
      listener.startScript label: 'Enter' if playerLocationId is nextLocationId

      @state 'currentLocation', nextLocationId

      @state 'lastAction', @constructor.ActionTypes.Move

  # Script

  initializeScript: ->
    @setThings @options.listener.avatars

  # Listener

  @avatars: ->
    shelley: PAA.Cast.Shelley
    coco: PAA.Cast.CoCo
    retro: PAA.Cast.Retro
