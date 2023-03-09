AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Interface extends LOI.Interface
  @register 'PixelArtAcademy.LearnMode.Interface'
  
  onCreated: ->
    super arguments...
    
    console.log "Text interface is being created." if LM.debug
    
    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 240
      maxDisplayWidth: 480
      maxDisplayHeight: 360
      minScale: LOI.settings.graphics.minimumScale.value
      maxScale: LOI.settings.graphics.maximumScale.value
      debug: false

    @studio = new @constructor.Studio

    # Automatically switch between the main menu and play focus
    @autorun (computation) =>
      return unless @studio.isRendered()
      
      locationId = LOI.adventure.currentLocationId()
      focusPoints = @constructor.Studio.FocusPoints
  
      focusPoint = if locationId is LM.Locations.MainMenu.id() then focusPoints.MainMenu else focusPoints.Play
      @studio.moveFocus focusPoint
