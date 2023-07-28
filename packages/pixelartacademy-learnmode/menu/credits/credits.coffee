AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Menu.Credits extends AM.Component
  @id: -> 'PixelArtAcademy.LearnMode.Menu.Credits'
  @url: -> 'credits'
  
  @version: -> '0.1.0'

  @register @id()
  
  @show: ->
    LOI.adventure.showActivatableModalDialog
      dialog: new LM.Menu.Credits
  
  LOI.Adventure.registerDirectRoute "/#{@url()}", =>
    @show() unless _.find LOI.adventure.modalDialogs(), (modalDialog) => modalDialog.dialog instanceof @
  
  mixins: -> [@activatable]
  
  constructor: ->
    super arguments...
    
    @activatable = new LOI.Components.Mixins.Activatable
    
    @initialAutoScrollTimeout = 1
    @autoScrollTimeout = 0.1
    @scrollSpeed = 20 # rem / s
    
  onCreated: ->
    super arguments...
    
    @app = @ancestorComponentOfType Artificial.Base.App
    @app.addComponent @
    
    @_autoScrollTimeoutLeft = @initialAutoScrollTimeout
  
  onRendered: ->
    super arguments...
    
    @$creditsArea = @$('.credits-area')
    
  onDestroyed: ->
    super arguments...
    
    @app.removeComponent @
  
  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500
    
  draw: (appTime) ->
    if @_autoScrollTimeoutLeft >= 0
      @_autoScrollTimeoutLeft -= appTime.elapsedAppTime
      @_scrollTop = @$creditsArea.scrollTop()
      return
    
    scale = LOI.adventure.interface.display.scale()
    
    @_scrollTop += @scrollSpeed * appTime.elapsedAppTime * scale
    
    @$creditsArea.scrollTop @_scrollTop
    
  events: ->
    super(arguments...).concat
      'wheel': @onWheel
    
  onWheel: (event) ->
    @_autoScrollTimeoutLeft = @autoScrollTimeout
