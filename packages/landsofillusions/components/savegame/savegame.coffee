AB = Artificial.Babel
AC = Artificial.Control
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.SaveGame extends AM.Component
  @id: -> 'LandsOfIllusions.Components.SaveGame'
  @register @id()

  @url: -> 'savegame'
  
  @version: -> '0.0.1'
  
  constructor: (@options) ->
    super arguments...
  
    @activatable = new LOI.Components.Mixins.Activatable()
  
  mixins: -> [@activatable]
  
  onCreated: ->
    super arguments...
    
  show: ->
    LOI.adventure.showActivatableModalDialog
      dialog: @
      dontRender: true
