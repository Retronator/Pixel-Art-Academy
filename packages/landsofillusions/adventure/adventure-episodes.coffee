AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeEpisodes: ->
    PAA = PixelArtAcademy

    # Global classes.
    @globalClasses = [
      PAA.Items
    ]

    @globals = for globalClass in @globalClasses
      new globalClass

    # Create episodes.
    @episodeClasses = [
      PAA.Season1.Episode0
    ]

    @episodes = new ReactiveField []

    @resetEpisodes()

    @currentChapters = new ComputedField =>
      chapters = _.flattenDeep (episode.currentChapters() for episode in @episodes())

      _.without chapters, null, undefined

    @currentSections = new ComputedField =>
      chapterSections = (chapter.currentSections() for chapter in @currentChapters())
      startSections = (episode.startSection for episode in @episodes() when not episode.startSection.finished())

      _.flattenDeep [chapterSections, startSections]
      
    @currentScenes = new ComputedField =>
      # Add scenes in decreasing order of priority (most general things first, specific overrides later)
      scenes = _.flattenDeep [
        global.scenes() for global in @globals
        @currentRegion()?.scenes()
        episode.scenes() for episode in @episodes()
        chapter.scenes() for chapter in @currentChapters()
        section.scenes() for section in @currentSections()
      ]

      _.without scenes, null, undefined

    # Active scenes are the ones at current location/time and contribute to current situation.
    @activeScenes = new ComputedField =>
      currentLocation = @currentLocation()
      currentTimelineId = @currentTimelineId()

      scenes = []

      for scene in LOI.adventure.currentScenes()
        # We compare IDs since we can get in a class or an instance.
        currentLocationClass = currentLocation.constructor
        sceneLocation = scene.location()
        validLocation = not sceneLocation or (currentLocationClass is sceneLocation) or (currentLocationClass in sceneLocation)

        sceneTimelineId = scene.timelineId()
        validTimeline = not sceneTimelineId or (currentTimelineId is sceneTimelineId) or (currentTimelineId in sceneTimelineId)

        scenes.push scene if validLocation and validTimeline

      scenes

  resetEpisodes: ->
    # Destroy previous episodes.
    episode.destroy() for episode in @episodes()

    # Create new ones.
    episodes = for episodeClass in @episodeClasses
      new episodeClass

    # Update main episodes field to trigger reactive re-creation of all storylines.
    @episodes episodes

  episodesReady: ->
    return false unless LOI.adventureInitialized()

    _.every (episode.ready() for episode in @episodes())
