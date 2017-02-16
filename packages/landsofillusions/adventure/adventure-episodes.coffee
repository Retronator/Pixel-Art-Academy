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

    @currentChapters = new ComputedField =>
      chapters = (episode.currentChapter() for episode in @episodes)
      _.without chapters, null

    @currentSections = new ComputedField =>
      sections = for chapter in @currentChapters()
        chapter.currentSections()

      _.flattenDeep sections

    @currentScenes = new ComputedField =>
      currentLocation = @currentLocation()

      scenes = for section in @currentSections()
        scene for scene in section.scenes when scene.location().id() is currentLocation.id()

      _.flattenDeep scenes

  resetEpisodes: ->
    episode.destroy() for episode in @episodes

    @_initializeEpisodes()

  episodesReady: ->
    return false unless LOI.adventureInitialized()

    _.every (episode.ready() for episode in @episodes)
