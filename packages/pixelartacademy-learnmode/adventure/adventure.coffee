AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Persistence = Artificial.Mummification.Document.Persistence

import semver from 'semver'

# The adventure component that is served from pixelart.academy/learn-mode.
class LM.Adventure extends PAA.Adventure
  @id: -> 'PixelArtAcademy.LearnMode.Adventure'
  @register @id()

  @title: ->
    "Pixel Art Academy: Learn Mode"

  @description: ->
    "Learn pixel art fundamentals in the educational game by Retronator."
  
  @rootUrl: -> '/learn-mode'

  @menuItemsClass: -> LM.Menu.Items
  
  @interfaceClass: -> LM.Interface

  @episodeClasses: -> [
    LM.Intro
    LM.PixelArtFundamentals
  ]
  
  @lastNewLessonsVersion: -> '0.25.0'
  
  constructor: ->
    super arguments...
    
    @isLearnMode = true
  
  titleSuffix: -> ' // Pixel Art Academy: Learn Mode'

  title: ->
    # On the landing page return the default title.
    return @constructor.title() if LOI.adventureInitialized() and @currentLocation()?.isLandingPage?()

    super arguments...

  template: -> 'LandsOfIllusions.Adventure'

  startingPoint: ->
    locationId: LM.Locations.MainMenu.id()
    timelineId: LOI.TimelineIds.RealLife

  usesLocalState: -> true
  
  getLocalSyncedStorage: -> new Persistence.SyncedStorages.LocalStorage storageKey: "Retronator"
  
  globalClasses: -> [
  
  ]
  
  episodeClasses: -> @constructor.episodeClasses()
  
  startNewGame: ->
    await super arguments...
    
    if gameState = LOI.adventure.gameState()
      # Automatically acknowledge the lessons in the current version on start.
      gameState.acknowledgedNewLessonsVersion = @constructor.lastNewLessonsVersion()
      LOI.adventure.gameState.updated()

  loadGame: ->
    await super arguments...
    await _.waitForFlush()

    @interface.prepareLocation()
    
    # Warn the user that new lessons were added.
    if gameState = LOI.adventure.gameState()
      acknowledgedNewLessonsVersion = gameState.acknowledgedNewLessonsVersion or '0.0.0'
      lastNewLessonsVersion = @constructor.lastNewLessonsVersion()
      
      if semver.lt acknowledgedNewLessonsVersion, lastNewLessonsVersion
        LOI.adventure.showDialogMessage """
          New tutorial lessons have been added since you last played the game. If anything in the game seems missing,
          complete the new lessons first to get back to where you were.

          Use the Progress screen in the Menu to see which tutorials you're missing.
        """
        
        , =>
          gameState.acknowledgedNewLessonsVersion = lastNewLessonsVersion
          LOI.adventure.gameState.updated()

  showLoading: ->
    # Don't show the loading screen if the interface is already indicating we're waiting.
    return if LOI.adventure.interface.waiting()
    
    super arguments...
    
  inAudioMenu: ->
    return unless LOI.adventureInitialized()
    
    if LOI.adventure.menu.visible()
      LOI.adventure.menu.items.inAudio()
      
    else if @interface.audio.focusPoint.value() is LM.Interface.FocusPoints.MainMenu
      LOI.adventure.currentLocation()?.menuItems?.inAudio()
