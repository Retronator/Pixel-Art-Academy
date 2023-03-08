LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

Persistence = Artificial.Mummification.Document.Persistence

# The adventure component that is served from pixelart.academy/learn-mode.
class LM.Adventure extends LOI.Adventure
  @id: -> 'PixelArtAcademy.LearnMode.Adventure'
  @register @id()

  @title: ->
    "Pixel Art Academy: Learn Mode // The most fun way to learn pixel art"

  @description: ->
    "Learn pixel art fundamentals in the educational game by Retronator."
  
  @rootUrl: -> '/learn-mode'

  @menuItemsClass: -> LM.Menu.Items
  
  @interfaceClass: -> LM.Interface

  @episodeClasses = []

  titleSuffix: -> ' // Pixel Art Academy: Learn Mode'

  title: ->
    # On the landing page return the default title.
    return @constructor.title() if LOI.adventureInitialized() and @currentLocation()?.isLandingPage?()

    super arguments...

  template: -> 'LandsOfIllusions.Adventure'

  startingPoint: ->
    locationId: PAA.LearnMode.MainMenu.id()
    timelineId: LOI.TimelineIds.RealLife

  usesLocalState: -> true
  
  getLocalSyncedStorage: -> new Persistence.SyncedStorages.LocalStorage storageKey: "Retronator"
  
  globalClasses: -> []
  
  episodeClasses: -> @constructor.episodeClasses
