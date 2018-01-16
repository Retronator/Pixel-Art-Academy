AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends AM.Component
  @id: -> 'LandsOfIllusions.Adventure'

  @title: ->
    "Lands of Illusions // Alternate Reality World"
    
  @description: ->
    "Imagination is the limit with Retronator's alternate reality system. Try it today!"

  @image: ->
    Meteor.absoluteUrl "pixelartacademy/title.png"
    
  titleSuffix: -> ' // Lands of Illusions'

  title: ->
    return @constructor.title() unless LOI.adventureInitialized()

    name = @activeItem()?.fullName() or @currentLocation()?.fullName()

    return @constructor.title() unless name

    "#{_.upperFirst name}#{@titleSuffix()}"

  usesLocalState: ->
    # Override to true to allow logged out users to play (they will store the state in local storage).
    false

  usesDatabaseState: ->
    # Override to false to force logged in users to use the main adventure route.
    true

  startingPoint: ->
    # Override and return {locationId, timelineId} to set a starting point.
    null

  ready: ->
    currentTimelineId = @currentTimelineId()
    currentLocation = @currentLocation()
    currentRegion = @currentRegion()

    conditions = [
      @parser.ready()
      @interface.ready()
      currentTimelineId
      if currentLocation? then currentLocation.ready() else false
      if currentRegion? then currentRegion.ready() else false
      @episodesReady()
    ]

    console.log "Adventure ready?", conditions if LOI.debug

    _.every conditions

  showLoading: ->
    # Show the loading screen when we're logging out.
    return true if @loggingOut()

    # Show the loading screen when we're not ready, except when other dialogs are already present
    # (for example, the storyline title) and we want to prevent the black blink in that case.
    not @ready() and not @modalDialogs().length

  logout: (options = {}) ->
    # Indicate logout procedure.
    @loggingOut true

    # Notify game state that it should flush any cached updates.
    if @gameState
      @gameState.updated
        flush: true
        callback: =>
          @_endLogout options

    else
      @_endLogout options

  _endLogout: (options) ->
    # Log out the user.
    Meteor.logout()

    # Now that there is no more user, wait until game state has returned to local storage.
    Tracker.autorun (computation) =>
      return unless LOI.adventure.gameStateSource() is LOI.Adventure.GameStateSourceType.LocalStorageUser
      computation.stop()

      Tracker.nonreactive =>
        # Inform the caller that the log out procedure has completed.
        options.callback?()

        # Notify that we're done with logout procedure.
        @loggingOut false

  showDescription: (thing) ->
    @interface.showDescription thing
