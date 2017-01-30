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
    console.log "Am I ready? Parser:", @parser.ready(), "Current location:", @currentLocation()?.ready() if LOI.debug
    @parser.ready() and @currentLocation()?.ready()

  logout: ->
    # Notify game state that it should flush any cached updates.
    @gameState?.updated flush: true

    # Log out the user.
    Meteor.logout()

  showDescription: (thing) ->
    @interface.showDescription thing

  # Tracking of modal dialogs, so that the interface can know when to listen for input events.

  addModalDialog: (dialog) ->
    @_modalDialogs.push dialog
    @_modalDialogsDependency.changed()

  removeModalDialog: (dialog) ->
    @_modalDialogs.splice @_modalDialogs.indexOf(dialog), 1
    @_modalDialogsDependency.changed()

  modalDialogs: (dialog) ->
    @_modalDialogsDependency.depend()
    @_modalDialogs
