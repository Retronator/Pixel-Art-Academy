AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Persistence = Artificial.Mummification.Document.Persistence

# The adventure component that is served from pixelart.academy/learn-mode.
class PAA.LearnMode.Adventure extends LOI.Adventure
  @id: -> 'PixelArtAcademy.Adventure'
  @register @id()

  @title: ->
    "Pixel Art Academy: Learn Mode // The most fun way to learn pixel art"

  @description: ->
    "Learn pixel art fundamentals in the educational game by Retronator."

  @episodeClasses = [
    PAA.LearnMode.Something
  ]
  
  titleSuffix: -> ' // Pixel Art Academy: Learn Mode'

  title: ->
    # On the landing page return the default title.
    return @constructor.title() if LOI.adventureInitialized() and @currentLocation()?.isLandingPage?()

    super arguments...

  template: -> 'LandsOfIllusions.Adventure'

  startingPoint: ->
    locationId: PAA.LearnMode.MainMenu.id()
    timelineId: LOI.TimelineIds.RealLife

  getLocalSyncedStorage: -> new Persistence.SyncedStorages.LocalStorage
  
  globalClasses: -> []
  
  episodeClasses: -> @constructor.episodeClasses
