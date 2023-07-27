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