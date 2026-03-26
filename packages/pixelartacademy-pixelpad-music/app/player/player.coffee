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
      buttonPan: AEc.ValueTypes.Number
      
  constructor: (@music) ->
    super arguments...
    
  onCreated: ->
    super arguments...
    
    # If the play button is pressed, make sure music can be heard.
    @autorun (computation) =>
      return unless PAA.PixelPad.Systems.Music.state 'playing'
      return if LOI.adventure.menu.visible()
      
      if LOI.settings.audio.enabled.value() is LOI.Settings.Audio.Enabled.Off
        message = "Audio is disabled. Would you like to enable it to play music?"
      
      else if LOI.settings.audio.mainVolume.value() is 0
        message = "The main volume is set to zero. Would you like to increase it to play music?"
        
      else if LOI.settings.audio.musicVolume.value() is 0
        message = "The music volume is set to zero. Would you like to increase it to play music?"
        
      else
        return
      
      dialog = new LOI.Components.Dialog
        message: message
        buttons: [
          text: "Yes"
          value: true
        ,
          text: "No"
        ]
    
      LOI.adventure.showActivatableModalDialog
        dialog: dialog
        callback: => @_enableAudioOrStopPlay dialog.result
        
  _enableAudioOrStopPlay: (enable) ->
    if enable
      if LOI.settings.audio.enabled.value() is LOI.Settings.Audio.Enabled.Off
        LOI.settings.audio.enabled.value LOI.Settings.Audio.Enabled.On
      
      if LOI.settings.audio.mainVolume.value() is 0
        LOI.settings.audio.mainVolume.value 1
      
      if LOI.settings.audio.musicVolume.value() is 0
        LOI.settings.audio.musicVolume.value 1
        
    else
      @music.system().stop()
    
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
      'pointerup .stop.button': @onPointerUpStopButton
      'pointerup .rewind.button': @onPointerUpRewindButton
      'pointerup .fast-forward.button': @onPointerUpFastForwardButton
      'click .inlay .track': @onClickInlayTrack

  onPointerDownPlayButton: (event) ->
    @music.system().play()
  
  onPointerDownStopButton: (event) ->
    @music.system().stop()
    
    # If the music will stop and trigger its own audio, the press sound is not needed.
    @_pressButtonAudio event unless PAA.PixelPad.Systems.Music.state 'playing'
  
  onPointerDownEjectButton: (event) ->
    @music.unloadTape()
    
  onPointerDownRewindButton: (event) ->
    @music.system().rewindOrPreviousTrack()
    @_pressButtonAudio event
  
  onPointerDownFastForwardButton: (event) ->
    @music.system().nextTrack()
    @_pressButtonAudio event
    
  _pressButtonAudio: (event) ->
    @audio.buttonPan AEc.getPanForElement event.target
    @audio.buttonPress()
    
  onPointerUpStopButton: (event) ->
    @_releaseButtonAudio()
  
  onPointerUpRewindButton: (event) ->
    @_releaseButtonAudio()
  
  onPointerUpFastForwardButton: (event) ->
    @_releaseButtonAudio()
    
  _releaseButtonAudio: ->
    @audio.buttonRelease()
  
  onClickInlayTrack: (event) ->
    track = @currentData()
    tape = @music.displayedTape()
    
    for side, sideIndex in tape.sides
      for sideTrack, trackIndex in side.tracks when track.url is sideTrack.url
        @music.system().setTrack sideIndex, trackIndex
