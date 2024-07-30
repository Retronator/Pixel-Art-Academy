AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Persistence = Artificial.Mummification.Document.Persistence

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

  loadGame: ->
    await super arguments...
    await _.waitForFlush()

    @interface.prepareLocation()
    
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
