AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Persistence = Artificial.Mummification.Document.Persistence

# The adventure component that is served from pixelart.academy.
class PAA.Adventure extends LOI.Adventure
  @id: -> 'PixelArtAcademy.Adventure'
  @register @id()

  @title: ->
    "Pixel Art Academy // Adventure game for learning how to draw"

  @description: ->
    "Become an artist in the text/point-and-click adventure game by Retronator."

  @userEpisodeClasses = [
    PAA.Season1.Episode0
  ]

  @characterEpisodeClasses = [
    PAA.Season1.Episode1
  ]
  
  titleSuffix: -> ' // Pixel Art Academy'

  title: ->
    # On the landing page return the default title.
    return @constructor.title() if LOI.adventureInitialized() and @currentLocation()?.isLandingPage?()

    super arguments...

  template: -> 'LandsOfIllusions.Adventure'

  startingPoint: ->
    locationId: Retropolis.Spaceport.AirportTerminal.Terrace.id()
    timelineId: PAA.TimelineIds.DareToDream
  
  usesLocalState: -> true

  getLocalSyncedStorage: -> new Persistence.SyncedStorages.LocalStorage
  
  globalClasses: -> [
    LOI.Character.Agents
    LOI.Memory.Flashback
    PAA.Items
    PAA.StudyGuide.Global
  ]
  
  episodeClasses: ->
    # Depend on character ID.
    characterId = LOI.characterId()
    
    if characterId then @constructor.characterEpisodeClasses else @constructor.userEpisodeClasses

  onCreated: ->
    super arguments...
    
    @_initializeGroups()
  
    # Subscribe to user's characters.
    LOI.Character.forCurrentUser.subscribe()
  
  _initializeGroups: ->
    # Subscribe to character's groups.
    @autorun (computation) =>
      return unless characterId = LOI.characterId()
    
      LOI.Character.Group.forCharacterId.subscribe characterId

  _initializeThings: ->
    super arguments...
  
    @currentStudents = new ComputedField =>
      _.filter @currentLocationThings(), (thing) => thing.is PAA.Student
