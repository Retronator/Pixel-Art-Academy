AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends AM.Component
  @title: ->
    "Pixel Art Academy // Adventure game for learning how to draw"
    
  @description: ->
    "Become an art student in the text/point-and-click adventure by Retronator."

  @image: ->
    Meteor.absoluteUrl "pixelartacademy/title.png"

  ready: ->
    currentLocation = @currentLocation()
    currentRegion = @currentRegion()

    conditions = [
      @parser.ready()
      @interface.ready()
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
    @gameState?.updated
      flush: true
      callback: =>
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
