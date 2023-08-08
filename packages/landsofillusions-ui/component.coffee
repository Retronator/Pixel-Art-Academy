AE = Artificial.Everywhere
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
Persistence = Artificial.Mummification.Document.Persistence

class LOI.Component extends AM.Component
  constructor: (@options = {}) ->
    super arguments...
    
    @audio = @constructor.Audio?.variables
  
  onCreated: ->
    super arguments...
    
    @constructor.Audio?.load LOI.adventure.interface.audioManager
  
  onDestroyed: ->
    super arguments...
    
    @constructor.Audio?.unload()
