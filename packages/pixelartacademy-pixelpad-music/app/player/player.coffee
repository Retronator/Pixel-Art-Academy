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
    
  trayOpenClass: ->
    'open' unless @music.loadedTape()
    
  playActiveClass: ->
    'active' if PAA.PixelPad.Systems.Music.state 'playing'
    
  tapeDisplayedClass: ->
    'displayed' if @music.loadedTape()

  events: ->
    super(arguments...).concat
      'pointerdown .play.button': @onPointerDownPlayButton
      'pointerdown .stop.button': @onPointerDownStopButton
      'pointerdown .eject.button': @onPointerDownEjectButton
      'pointerdown .rewind.button': @onPointerDownRewindButton
      'pointerdown .fast-forward.button': @onPointerDownFastForwardButton
      'click .inlay .track': @onClickInlayTrack

  onPointerDownPlayButton: (event) ->
    @music.system().play()
    
    @audio.buttonPress()
  
  onPointerDownStopButton: (event) ->
    @music.system().stop()
    
    @audio.buttonPress()
  
  onPointerDownEjectButton: (event) ->
    @music.unloadTape()
    
  onPointerDownRewindButton: (event) ->
    @music.system().rewindOrPreviousTrack()
  
  onPointerDownFastForwardButton: (event) ->
    @music.system().nextTrack()
  
  onClickInlayTrack: (event) ->
    track = @currentData()
    tape = @music.displayedTape()
    
    for side, sideIndex in tape.sides
      for sideTrack, trackIndex in side.tracks when track.url is sideTrack.url
        @music.system().setTrack sideIndex, trackIndex
