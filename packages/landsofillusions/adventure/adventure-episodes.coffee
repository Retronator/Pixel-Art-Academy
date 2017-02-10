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
      episode.currentChapter() for episode in @episodes

    @currentSections = new ComputedField =>
      sections = for chapter in @currentChapters()
        chapter.currentSections()

      _.flattenDeep sections

    # We use a cache to avoid reconstruction.
    @_scenes = {}

    @currentScenes = new ComputedField =>
      currentLocation = @currentLocation()

      scenes = for section in @currentSections()
        for sceneClass in section.constructor.scenes() when sceneClass.location().id() is currentLocation.id()
          # Create the scene if needed. We create the instance in a non-reactive
          # context so that reruns of this autorun don't invalidate instance's autoruns.
          Tracker.nonreactive =>
            @_scenes[sceneClass.id()] ?= new sceneClass

          @_scenes[sceneClass.id()]

      _.flattenDeep scenes
