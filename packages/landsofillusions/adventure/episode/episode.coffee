AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Adventure.Episode extends LOI.Adventure.Thing
  @chapters: -> throw new AE.NotImplementedException

  @_episodeClassesById = {}

  @getClassForId: (id) ->
    @_episodeClassesById[id]

  @initialize: ->
    super

    @_episodeClassesById[@id()] = @

  @timelineId: -> # Override to set a default timeline for scenes.
  timelineId: -> @constructor.timelineId()

  @startSection: -> throw new AE.NotImplementedException

  constructor: ->
    super

    startSectionClass = @constructor.startSection()
    @startSection = new startSectionClass
      parent: @

    @chapters = []

    @currentChapters = new ComputedField =>
      return unless LOI.adventureInitialized()
      return unless LOI.adventure.gameState()

      # Episode chapters are active only if the start section was completed.
      return [] unless @startSection.finished()

      currentChapters = []

      # Add chapters up to including the one that isn't finished yet.
      for chapterClass, chapterIndex in @constructor.chapters()
        # Instantiate the chapter if needed.
        Tracker.nonreactive =>
          @chapters[chapterIndex] ?= new chapterClass episode: @

        currentChapters[chapterIndex] = @chapters[chapterIndex]

        # Don't add further chapters if this one wasn't finished.
        break unless @chapters[chapterIndex].finished()

      currentChapters
    ,
      true

  destroy: ->
    super

    chapter.destroy() for chapter in @chapters

    @startSection.destroy()

  scenes: -> # Override to provide any scenes for the whole episode.

  ready: ->
    # Episode is ready when its current chapters are ready.
    return unless currentChapters = @currentChapters()

    conditions = _.flattenDeep [
      super
      chapter.ready() for chapter in currentChapters
    ]

    _.every conditions
