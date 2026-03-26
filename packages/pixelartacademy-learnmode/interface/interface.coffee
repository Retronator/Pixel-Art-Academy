AC = Artificial.Control
AE = Artificial.Everywhere
AEc = Artificial.Echo
AMe = Artificial.Melody
AM = Artificial.Mirage
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Interface extends LOI.Interface
  @id: -> 'PixelArtAcademy.LearnMode.Interface'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      focusPoint: AEc.ValueTypes.String
      playAmbient: AEc.ValueTypes.Boolean
      inGameMusicInLocation: AEc.ValueTypes.Boolean
    
  @FocusPoints:
    Play: 'Play'
    MainMenu: 'MainMenu'
  
  @InGameMusicMode:
    Direct: 'Direct'
    InLocation: 'InLocation'
    Off: 'Off'
  
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
    
    # Manually load Audio since audio manager wasn't available when calling super.
    @constructor.Audio.load LOI.adventure.audioManager
    
    # Play ambient in play mode, but not in the menus, except in the audio sections. We have an additional extended
    # silence during quitting when the game transitions from the play to the main menu location and audio would still
    # be played as the adventure menu fades out before location switch.
    @quitting = new ReactiveField false
    
    @audioOffInMenus = new ComputedField =>
      if @audio.focusPoint.value() is @constructor.FocusPoints.Play
        if LOI.adventure.menu.visible()
          not LOI.adventure.menu.items.inAudioSubmenus()
          
        else
          @quitting()
      
      else
        not LOI.adventure.currentLocation()?.menuItems?.inAudioSubmenus()
    
    @autorun (computation) =>
      @audio.playAmbient not @audioOffInMenus()
    
    # Allow for focusing artworks.
    @focusedArtworks = new ReactiveField null
    
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

  goToPlay: (loadProfileId) ->
    mainMenu = LOI.adventure.currentLocation()
    mainMenu.fadeOut()

    @audio.focusPoint @constructor.FocusPoints.Play
    
    Meteor.setTimeout =>
      # Move the focus point.
      await @studio.moveFocus
        focusPoint: @constructor.Studio.FocusPoints.Play
        speedFactor: if loadProfileId then 2.5 else 1.5
        
      if loadProfileId
        # Start loading the game after the animation has finished to prevent lag.
        await LOI.adventure.menu.loadGame.show loadProfileId, false

      else
        # We are starting a new game, show the save dialog.
        await LOI.adventure.menu.saveGame.show()
      
      # If the player decided to cancel or the load didn't succeed, send them back to the menu.
      unless LOI.adventure.profile().hasSyncing()
        LOI.adventure.quitGame callback: =>
          LOI.adventure.interface.goToMainMenu()
    
          # Notify that we've handled the quitting sequence.
          true
          
        return
          
      # We have a profile loaded with syncing, so we can safely continue to play.
      LOI.adventure.goToLocation LM.Locations.Play unless loadProfileId
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
      speedFactor: 2
    
    mainMenu = LOI.adventure.currentLocation()
    mainMenu.fadeIn()

    @waiting false
  
  startWaiting: ->
    @waiting true
    
  focusArtworks: (artworks, options) ->
    # Start display.
    @focusedArtworks
      artworks: artworks
      options: _.defaults {}, options,
        scrollParentSelector: '.focused-artworks'

  unfocusArtworks: ->
    # Stop display.
    @focusedArtworks null
    
  active: ->
    # The Learn Mode interface is inactive when adventure is paused.
    return if LOI.adventure.paused()
    
    # Inactive when the menu is opened.
    return if LOI.adventure.menu.visible()
    
    true

  introFadeCompleteClass: ->
    'complete' if @introFadeComplete()
  
  introFadeFastClass: ->
    'fast' if @introFadeFast()
  
  waitingOverlayVisibleClass: ->
    'visible' if @waiting()
    
  artworksStreamOptions: -> @focusedArtworks().options
  
  events: ->
    super(arguments...).concat
      'click .focused-artworks': @onClickFocusedArtworks
  
  onClickFocusedArtworks: (event) ->
    @unfocusArtworks()
