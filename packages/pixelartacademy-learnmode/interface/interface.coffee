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

    @introFadeComplete = new ReactiveField false
    
    @waiting = new ReactiveField false
    
  onRendered: ->
    super arguments...
  
    # Wait until adventure is ready.
    @autorun (computation) =>
      return unless LOI.adventure.ready()
      computation.stop()
    
      @introFadeComplete true
  
      Meteor.setTimeout =>
        mainMenu = LOI.adventure.currentLocation()
        mainMenu.fadeIn()
      ,
        1000
    
  goToPlay: ->
    mainMenu = LOI.adventure.currentLocation()
    mainMenu.fadeOut()
    
    Meteor.setTimeout =>
      @studio.moveFocus
        focusPoint: @constructor.Studio.FocusPoints.Play
        speedFactor: 1.5
        completeCallback: =>
          LOI.adventure.goToLocation LM.Locations.Play
        
          # Open the PixelPad when it becomes available.
          @autorun (computation) =>
            return unless pixelBoy = LOI.adventure.getCurrentThing PAA.PixelBoy
            computation.stop()
            
            pixelBoy.open()
  
            LOI.adventure.interface.waiting false
    ,
      750
  
  goToMainMenu: ->
    @studio.moveFocus
      focusPoint: @constructor.Studio.FocusPoints.MainMenu
      speedFactor: 1.5
      completeCallback: =>
        mainMenu = LOI.adventure.currentLocation()
        mainMenu.fadeIn()
  
        LOI.adventure.interface.waiting false
        
  introFadeCompleteClass: ->
    'complete' if @introFadeComplete()
  
  waitingOverlayVisibleClass: ->
    'visible' if @waiting()
