AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeAudio: ->
    @audioManager = new LOI.Interface.Components.AudioManager
    LOI.Assets.Engine.Audio.initialize @audioManager
    
    @music = new LOI.Music @audioManager
  
  inAudioMenu: ->
    # TODO: Implement for Adventure Mode.

  update: (appTime) ->
    super arguments...
    
    @music.update appTime
