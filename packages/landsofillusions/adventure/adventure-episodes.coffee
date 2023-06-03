AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  episodeClasses: ->
    # Override to provide classes for adding chapters, sections, and scenes.
    []
    
  globalClasses: ->
    # Override to provide classes that return scenes which should be available everywhere.
    []
  
  _initializeEpisodes: ->
    # Global classes.
    @globals = new AE.ReactiveInstances => @globalClasses()

    # Create episodes.
    @_resetEpisodesDependency = new Tracker.Dependency
    
    @episodes = new ComputedField =>
      console.log "Recomputing episodes." if LOI.debug

      # Allow resetting of episodes.
      @_resetEpisodesDependency.depend()

      # Destroy previous episodes.
      episode.destroy() for episode in @_episodes if @_episodes
  
      # Create new ones.
      Tracker.nonreactive =>
        @_episodes = for episodeClass in @episodeClasses()
          new episodeClass

      @_episodes
    ,
      true

    @currentChapters = new ComputedField =>
      chapters = _.flattenDeep (episode.currentChapters() for episode in @episodes())

      _.without chapters, null, undefined
    ,
      true

    @currentSections = new ComputedField =>
      chapterSections = (chapter.currentSections() for chapter in @currentChapters())
      startSections = (episode.startSection for episode in @episodes() when not episode.startSection.finished())

      _.flattenDeep [chapterSections, startSections]
    ,
      true
      
    @currentScenes = new ComputedField =>
      # Add scenes in decreasing order of priority (most general things first, specific overrides later)
      scenes = _.flattenDeep [
        global.scenes() for global in @globals()
        @currentRegion()?.scenes()
        episode.scenes() for episode in @episodes()
        chapter.scenes() for chapter in @currentChapters()
        section.scenes() for section in @currentSections()
      ]

      _.without scenes, null, undefined
    ,
      true

    # Active scenes are the ones at current location/time and contribute to current situation.
    @activeScenes = new ComputedField =>
      return unless currentTimelineId = @currentTimelineId()
      return unless currentLocationId = @currentLocationId()

      scenes = []

      for scene in LOI.adventure.currentScenes()
        # We compare IDs since we can get in strings, classes or instances.
        sceneLocations = scene.location()

        # Allow single locations.
        if sceneLocations
          sceneLocations = [sceneLocations] unless _.isArray sceneLocations
          sceneLocationIds = (_.thingId sceneLocation for sceneLocation in sceneLocations)

        else
          sceneLocationIds = null

        # We can either not have a location specified (which
        # means it is always present), or the location needs to match.
        validLocation = not sceneLocationIds or (currentLocationId in sceneLocationIds)

        # Analyze timeline as well.
        sceneTimelineIds = scene.timelineId()

        # Allow single timelines.
        if sceneTimelineIds
          sceneTimelineIds = [sceneTimelineIds] unless _.isArray sceneTimelineIds

        # We can either not have a timeline specified (which
        # means it is always present), or the timeline needs to match.
        validTimeline = not sceneTimelineIds or (currentTimelineId in sceneTimelineIds)

        # We add the scene if it applies to this location and timeline.
        scenes.push scene if validLocation and validTimeline

      scenes
    ,
      true

  resetEpisodes: ->
    console.log "Resetting episodes." if LOI.debug
    @_resetEpisodesDependency.changed()

  getEpisode: (episodeClass) ->
    _.find @episodes(), (episode) => episode instanceof episodeClass

  getCurrentChapter: (chapterClass) ->
    _.find @currentChapters(), (chapter) => chapter instanceof chapterClass
