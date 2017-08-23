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
    @userEpisodeClasses = [
      PAA.Season1.Episode0
    ]

    @characterEpisodeClasses = [
      PAA.Season1.Episode1
    ]
    
    @_resetEpisodesDependency = new Tracker.Dependency
    
    @episodes = new ComputedField =>
      console.log "Recomputing episodes." if LOI.debug

      # Allow resetting of episodes.
      @_resetEpisodesDependency.depend()

      # Depend on character ID.
      characterId = LOI.characterId()
      
      # Destroy previous episodes.
      episode.destroy() for episode in @_episodes if @_episodes
  
      # Create new ones.
      Tracker.nonreactive =>
        if characterId
          @_episodes = for episodeClass in @characterEpisodeClasses
            new episodeClass

        else
          @_episodes = for episodeClass in @userEpisodeClasses
            new episodeClass

      @_episodes

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
    console.log "Resetting episodes." if LOI.debug
    @_resetEpisodesDependency.change()

  episodesReady: ->
    return false unless LOI.adventureInitialized()

    _.every (episode.ready() for episode in @episodes())
