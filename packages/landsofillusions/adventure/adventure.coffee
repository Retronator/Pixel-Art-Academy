AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends AM.Component
  @title: ->
    "Pixel Art Academy // Adventure game for learning how to draw"
    
  @description: ->
    "Become a pixel art student in the text/point-and-click adventure game by Retronator."

  @image: ->
    Meteor.absoluteUrl "pixelartacademy/title.png"

  ready: ->
    currentLocation = @currentLocation()
    currentRegion = @currentRegion()

    conditions = [
      @parser.ready()
      if currentLocation? then currentLocation.ready() else false
      if currentRegion? then currentRegion.ready() else false
      @episodesReady()
    ]

    console.log "Adventure ready?", conditions if LOI.debug

    _.every conditions

  logout: (options = {}) ->
    # Notify game state that it should flush any cached updates.
    @gameState?.updated
      flush: true
      callback: =>
        # Log out the user.
        Meteor.logout()

        # Now that there is no more user, wait until game state has returned to local storage.
        Tracker.autorun (computation) =>
          return unless LOI.adventure.gameStateSource() is LOI.Adventure.GameStateSourceType.LocalStorage
          computation.stop()

          Tracker.nonreactive =>
            # Inform the caller that the log out procedure has completed.
            options.callback?()

  showDescription: (thing) ->
    @interface.showDescription thing
