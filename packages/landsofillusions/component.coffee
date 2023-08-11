AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Component extends AM.Component
  constructor: (@options = {}) ->
    super arguments...
    
    @audio = @constructor.Audio?.variables
  
  onCreated: ->
    super arguments...
    
    if LOI.adventure.interface.audioManager
      @constructor.Audio?.load LOI.adventure.interface.audioManager
  
  onDestroyed: ->
    super arguments...
    
    @constructor.Audio?.unload()
