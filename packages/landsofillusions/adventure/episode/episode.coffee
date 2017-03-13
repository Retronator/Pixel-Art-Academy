AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Adventure.Episode extends LOI.Adventure.Thing
  @id: -> throw new AE.NotImplementedException
  @chapters: -> throw new AE.NotImplementedException

  @_episodeClassesById = {}

  @getClassForId: (id) ->
    @_episodeClassesById[id]

  @initialize: ->
    super

    @_episodeClassesById[@id()] = @

  constructor: ->
    super

    @currentChapter = new ReactiveField null

    @autorun (computation) =>
      return unless LOI.adventureInitialized()

      currentChapterId = @state 'currentChapter'

      # Start in first chapter, if none is set.
      currentChapterId ?= @constructor.chapters()[0].id()

      if currentChapterId isnt @_currentChapterId
        @_currentChapterId = currentChapterId

        for chapterClass in @constructor.chapters()
          currentChapterClass = chapterClass if chapterClass.id() is currentChapterId

        # Destroy the old chapter.
        @_currentChapter?.destroy()

        # Instantiate the chapter. We do it in a non-reactive context so that its autoruns don't get invalidated.
        Tracker.nonreactive =>
          @_currentChapter = new currentChapterClass episode: @

        @currentChapter @_currentChapter

  destroy: ->
    super

    @_currentChapter?.destroy()

  id: ->
    @constructor.id()

  ready: ->
    # Episode is ready when its current chapter is ready
    currentChapter = @currentChapter()

    conditions = _.flattenDeep [
      super
      if currentChapter? then currentChapter.ready() else false
    ]

    _.every conditions
