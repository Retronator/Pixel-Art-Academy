AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeEpisodes: ->
    PAA = PixelArtAcademy
    
    # Create episodes.
    @episodeClasses = [
      PAA.Season1.Episode0
    ]

    @episodes = for episodeClass in @episodeClasses
      new episodeClass

  currentChapters: ->
    episode.currentChapter() for episode in @episodes

  currentSections: ->
    sections = for chapter in @currentChapters()
      chapter.currentSections()

    _.flattenDeep sections

  currentScenes: ->
    currentLocation = @currentLocation()

    scenes = for section in @currentSections()
      for sceneClass in section.constructor.scenes() when sceneClass.location().id() is currentLocation.id()
        new sceneClass

    _.flattenDeep scenes

  currentThings: ->
    currentLocation = @currentLocation()

    locationThings = currentLocation.things()
    sceneThings = for scene in @currentScenes()
      scene.things()

    thingClasses = _.flattenDeep _.union locationThings, sceneThings

    for thingClass in thingClasses
      new thingClass
        location: currentLocation
