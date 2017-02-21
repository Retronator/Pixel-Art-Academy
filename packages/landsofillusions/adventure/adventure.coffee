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

    conditions = [
      @parser.ready()
      if currentLocation? then currentLocation.ready() else false
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

  # Tracking of modal dialogs, so that the interface can know when to listen for input events.

  addModalDialog: (dialog) ->
    # We add new dialogs at the beginning so the first is the (assumed) top-most.
    @_modalDialogs.unshift dialog
    @_modalDialogsDependency.changed()

  removeModalDialog: (dialog) ->
    @_modalDialogs.splice @_modalDialogs.indexOf(dialog), 1
    @_modalDialogsDependency.changed()

  modalDialogs: (dialog) ->
    @_modalDialogsDependency.depend()
    @_modalDialogs
