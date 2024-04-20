AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class PAA.PixelPad.Apps.Pixeltosh extends PAA.PixelPad.App
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Pixeltosh'
  @url: -> 'pixeltosh'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Pixeltosh"
  @description: ->
    "
      It's a mini version of the Macintosh 128K!
    "

  @initialize()
  
  @getOS: ->
    return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
    return unless currentApp = pixelPad.os.currentApp()
    return unless currentApp instanceof @
    pixeltosh = currentApp
    pixeltosh.os()

  constructor: ->
    super arguments...
    
    @resizable false
    
    @os = new ReactiveField null

  onCreated: ->
    super arguments...

    @os new PAA.Pixeltosh.OS
    
    # Make the PixelPad as big as possible.
    @autorun (computation) =>
      maximumSize = @getMaximumPixelPadSize fullscreen: true
      width = _.clamp maximumSize.width, 320, 444
      height = maximumSize.height
      @setFixedPixelPadSize width, height
  
  onDestroyed: ->
    super arguments...
    
    @os null
  
  inGameMusicMode: ->
    # Turn off music when using the Pixeltosh.
    LM.Interface.InGameMusicMode.Off
