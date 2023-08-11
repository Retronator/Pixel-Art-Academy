AE = Artificial.Everywhere
AEc = Artificial.Echo
AM = Artificial.Mirage
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Interface extends LOI.Interface
  @id: -> 'PixelArtAcademy.LearnMode.Interface'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      focusPoint: AEc.ValueTypes.String
    
  @FocusPoints:
    Play: 'Play'
    MainMenu: 'MainMenu'
    
  onCreated: ->
    super arguments...
    
    console.log "Learn Mode interface is being created." if LM.debug
    
    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 241
      maxDisplayWidth: 480
      maxDisplayHeight: 360
      minScale: LOI.settings.graphics.minimumScale.value
      maxScale: LOI.settings.graphics.maximumScale.value
      debug: false

    @studio = new @constructor.Studio

    @introFadeComplete = new ReactiveField false
    @introFadeFast = new ReactiveField false
    
    @waiting = new ReactiveField true
    
    @audioManager = new LOI.Interface.Components.AudioManager
    
    LOI.Assets.Engine.Audio.initialize @audioManager
    
    # Manually load Audio since audio manager wasn't available when calling super.
    @constructor.Audio.load @audioManager
    
  onRendered: ->
    super arguments...
  
    # Wait until adventure is ready.
    @autorun (computation) =>
      return unless LOI.adventure.ready()
      computation.stop()
    
      if LOI.adventure.currentLocationId() is LM.Locations.MainMenu.id()
        # We're starting in the menu (such as when no profile has been stored as active yet), so simply fade it in.
        Meteor.setTimeout =>
          mainMenu = LOI.adventure.currentLocation()
          mainMenu.fadeIn()
          @audio.focusPoint @constructor.FocusPoints.MainMenu
          @waiting false
        ,
          1000
        
      else if LOI.adventure.currentLocationId() is LM.Locations.Play.id()
        # We're starting directly in play so we have to make the studio focus on the top and open the PixelPad.
        @studio.setFocus @constructor.Studio.FocusPoints.Play
        @audio.focusPoint @constructor.FocusPoints.Play
        Tracker.nonreactive => @_openPixelPad()
        
        # We want a fast transition since there is no waiting for the menu fade.
        @introFadeFast true
  
      @introFadeComplete true

  prepareLocation: ->
    if LOI.adventure.currentLocationId() is LM.Locations.Play.id()
      # We're supposed to be in play so we have to make the studio focus on the top and open the PixelPad.
      @studio.setFocus @constructor.Studio.FocusPoints.Play
      @audio.focusPoint @constructor.FocusPoints.Play
      @_openPixelPad()

    else
      @studio.setFocus @constructor.Studio.FocusPoints.MainMenu
      @audio.focusPoint @constructor.FocusPoints.MainMenu

  goToPlay: ->
    mainMenu = LOI.adventure.currentLocation()
    mainMenu.fadeOut()

    @audio.focusPoint @constructor.FocusPoints.Play
    
    Meteor.setTimeout =>
      await @studio.moveFocus
        focusPoint: @constructor.Studio.FocusPoints.Play
        speedFactor: 1.5

      # Show the save dialog if we're entering play without syncing.
      unless LOI.adventure.profile().hasSyncing()
        await LOI.adventure.menu.saveGame.show()
        
        # If the player decided to cancel, send them back to the menu.
        unless LOI.adventure.profile().hasSyncing()
          LOI.adventure.quitGame callback: =>
            LOI.adventure.interface.goToMainMenu()
      
            # Notify that we've handled the quitting sequence.
            true
            
          return
          
        # We have a profile loaded with syncing, so we can safely continue to play.
        LOI.adventure.goToLocation LM.Locations.Play
        @_openPixelPad()
    ,
      750
    
  _openPixelPad: ->
    # Open the PixelPad when it becomes available.
    @autorun (computation) =>
      return unless pixelPad = LOI.adventure.getCurrentThing PAA.PixelPad
      computation.stop()
    
      pixelPad.open()
    
      @waiting false
  
  goToMainMenu: ->
    @audio.focusPoint @constructor.FocusPoints.MainMenu
    
    await @studio.moveFocus
      focusPoint: @constructor.Studio.FocusPoints.MainMenu
      speedFactor: 1.5
    
    mainMenu = LOI.adventure.currentLocation()
    mainMenu.fadeIn()

    @waiting false
    
  introFadeCompleteClass: ->
    'complete' if @introFadeComplete()
  
  introFadeFastClass: ->
    'fast' if @introFadeFast()
  
  waitingOverlayVisibleClass: ->
    'visible' if @waiting()
