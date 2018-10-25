LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Scenes.Shelley extends LOI.Adventure.Scene
  @id: -> 'Retronator.HQ.Scenes.Shelley'

  @timelineId: -> [LOI.TimelineIds.RealLife, LOI.TimelineIds.Present]

  @initialize()

  @defaultScriptUrl: -> 'retronator_retronator-hq/scenes/shelley.script'

  @ActionTypes:
    Move: 'Move'
    Activity: 'Activity'

  constructor: ->
    super arguments...

    # Set starting location and start moving around.
    @autorun (computation) =>
      return unless LOI.adventure.gameState()
      computation.stop()

      @state 'currentLocation', HQ.GalleryEast.id() unless @state 'currentLocation'

      @_scheduleNextAction()

    @currentLocation = new ComputedField =>
      return unless currentLocationId = @currentLocationId()

      LOI.Adventure.Location.getClassForId currentLocationId

    # We want to run this script only when no-one else is using Shelley.
    @otherScenesUseShelley = new ComputedField =>
      for scene in LOI.adventure.currentScenes() when scene.things and scene isnt @
        for thingOrThingClass in scene.things() when thingOrThingClass?
          # Scenes can provide an instance, a class, or an inherited class of Shelley, so check for all.
          thingOrThingClassIsShelley = _.some [
            thingOrThingClass instanceof HQ.Actors.Shelley
            thingOrThingClass is HQ.Actors.Shelley
            thingOrThingClass.prototype instanceof HQ.Actors.Shelley
          ]

          return true if thingOrThingClassIsShelley

      false

  destroy: ->
    super arguments...

    Meteor.clearTimeout @_nextMessageTimeout

  currentLocationId: ->
    @state 'currentLocation'

  location: ->
    # Shelley changes location.
    LOI.Adventure.Location.getClassForId @currentLocationId()

  things: ->
    things = []

    things.push HQ.Actors.Shelley if LOI.adventure.currentLocationId() is @currentLocationId() and not @otherScenesUseShelley()

    things

  _scheduleNextAction: (options = {}) ->
    # Make the next action in 30-60 seconds.
    options.delay ?= (1 + Math.random()) * 30 * 1000

    @_nextActionTimeout = Meteor.setTimeout =>
      # Don't do the action if the user is busy doing something.
      if LOI.adventure.interface.busy() or LOI.adventure.currentContext()
        # Retry in 10 seconds.
        @_scheduleNextAction delay: 10000
        return

      # Don't do the action if any other scene is using Shelley.
      if @otherScenesUseShelley()
        @_scheduleNextAction()
        return

      # Looks OK, do something!
      @_doAction()

      @_scheduleNextAction()
    ,
      options.delay

  _doAction: ->
    return unless location = @location()
    return unless listener = @listeners[0]

    currentLocationId = @currentLocationId()
    playerLocationId = LOI.adventure.currentLocationId()

    lastAction = @state 'lastAction'

    if lastAction is @constructor.ActionTypes.Move or (not lastAction and Math.random() < 0.5)
      @state 'lastAction', @constructor.ActionTypes.Activity

      # Do an activity but only display it if we're at Shelley' location.
      return unless playerLocationId is currentLocationId

      switch location
        when HQ.GalleryEast
          choices = [
            # For the drinks dialogue, Corinne must be present.
            'Drinks' if LOI.adventure.getCurrentThing HQ.Actors.Corinne
          ]
        when HQ.GalleryWest then choices = ['Stare']
        when HQ.ArtStudio then choices = ['AhKids']
        when HQ.Store then choices = ['Melanija']
        else
          choices = []

      # Add choices that are always possible.
      choices = choices.concat ['Gold']

      # Remove any invalid choices.
      choices = _.without choices, undefined

      label = Random.choice choices

      listener.startBackgroundScript label: label

    else
      # Move.
      switch location
        when HQ.GalleryEast then choices = [HQ.GalleryWest]
        when HQ.GalleryWest then choices = [HQ.GalleryEast, HQ.ArtStudio, HQ.Store]
        when HQ.ArtStudio then choices = [HQ.GalleryWest]
        when HQ.Store then choices = [HQ.GalleryWest]

      nextLocationId = Random.choice(choices).id()

      listener.startBackgroundScript label: 'Leave' if playerLocationId is currentLocationId
      listener.startBackgroundScript label: 'Enter' if playerLocationId is nextLocationId

      @state 'currentLocation', nextLocationId

      @state 'lastAction', @constructor.ActionTypes.Move

  # Script

  initializeScript: ->
    @setThings @options.listener.avatars

  # Listener

  @avatars: ->
    shelley: HQ.Actors.Shelley
    corinne: HQ.Actors.Corinne
    retro: HQ.Actors.Retro
