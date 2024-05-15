AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Music.Player extends LOI.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Music.Player'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      buttonPress: AEc.ValueTypes.Trigger
      buttonRelease: AEc.ValueTypes.Trigger
      
  constructor: (@music) ->
    super arguments...
    
  onCreated: ->
    super arguments...

  events: ->
    super(arguments...).concat
      'click .play-button': @onClickPlayButton
      'click .stop-button': @onClickStopButton
      'click .eject-button': @onClickEjectButton

  onClickPlayButton: (event) ->
    @music.system().play()
    
    @audio.buttonPress()
  
  onClickStopButton: (event) ->
    @music.system().stop()
    
    @audio.buttonPress()
  
  onClickEjectButton: (event) ->
    @music.system().setTape null
    
    AB.Router.changeParameters
      parameter3: null
      parameter4: null
    
    @audio.buttonPress()
