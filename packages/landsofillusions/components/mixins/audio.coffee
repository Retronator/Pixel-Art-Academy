AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Mixins.Audio extends BlazeComponent
  constructor: (@audioComponent) ->
    super arguments...
    
    @audioComponent.audio = @audioComponent.constructor.Audio?.variables

  onCreated: ->
    super arguments...
    
    if LOI.adventure?.interface.audioManager
      @audioComponent.constructor.Audio?.load LOI.adventure.interface.audioManager
  
  onDestroyed: ->
    super arguments...
    
    @audioComponent.constructor.Audio?.unload()
