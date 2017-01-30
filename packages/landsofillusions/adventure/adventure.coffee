AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends AM.Component
  @title: ->
    "Pixel Art Academy // Adventure game for learning how to draw"
    
  @description: ->
    "A pixel art adventure about drawing, in development by Retronator."

  @image: ->
    Meteor.absoluteUrl "pixelartacademy/landingpage/pages/press/Pixel%20Art%20Academy%20Title.png"

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
