AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Adventure.Episode extends LOI.Adventure.Thing
  @chapters: -> throw new AE.NotImplementedException

  @_episodeClassesById = {}

  @getClassForId: (id) ->
    @_episodeClassesById[id]

  @initialize: ->
    super arguments...

    @_episodeClassesById[@id()] = @

  @timelineId: -> # Override to set a default timeline for scenes.
  timelineId: -> @constructor.timelineId()

  @scenes: -> [] # Override to provide any scenes for the whole episode.

  @startSection: -> throw new AE.NotImplementedException

  constructor: ->
    super arguments...

    startSectionClass = @constructor.startSection()
    @startSection = new startSectionClass
      parent: @

    previousChapter = null

    # TODO: Add support for non-linear chapters by sending a hierarchy object from the chapters function.
    @chapters = for chapterClass in @constructor.chapters()
      chapter = new chapterClass
        parent: @
        previousChapter: previousChapter

      previousChapter = chapter

      chapter

    @_scenes = for sceneClass in @constructor.scenes()
      new sceneClass parent: @

  destroy: ->
    super arguments...

    chapter.destroy() for chapter in @chapters
    scene.destroy() for scene in @_scenes

    @startSection.destroy()

  scenes: ->
    @_scenes

  currentChapters: ->
    # No chapters are active when the whole episode is not accessible.
    return [] unless @meetsAccessRequirement()

    chapter for chapter in @chapters when chapter.active()

  ready: ->
    # Episode is ready when its current chapters are ready.
    return unless currentChapters = @currentChapters()

    conditions = _.flattenDeep [
      super arguments...
      chapter.ready() for chapter in currentChapters
    ]

    _.every conditions

  showEpisodeTitle: (options = {}) ->
    options = _.extend
      episode: @
    ,
      options
      
    # Show to be continued screen if the player doesn't have access yet (assuming in the future it will be available).
    options.toBeContinued = true unless @meetsAccessRequirement()
    
    # Create new storyline title.
    episodeTitle = new LOI.Components.StorylineTitle options

    LOI.adventure.showActivatableModalDialog
      dialog: episodeTitle
