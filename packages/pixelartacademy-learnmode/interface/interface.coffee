AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Interface extends LOI.Interface
  @register 'PixelArtAcademy.LearnMode.Interface'
  
  onCreated: ->
    super arguments...
    
    console.log "Text interface is being created." if PAA.LearnMode.debug
    
    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 240
      maxDisplayWidth: 480
      maxDisplayHeight: 640
      minScale: LOI.settings.graphics.minimumScale.value
      maxScale: LOI.settings.graphics.maximumScale.value
      minAspectRatio: 1 / 2
      maxAspectRatio: 2
      debug: false
