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

    @currentChapter = new ComputedField =>
      currentChapterId = @state 'currentChapter'

      if currentChapterId
        for chapterClass of @constructor.chapters
          currentChapterClass = chapterClass if chapterClass.id() is currentChapterId

      else
        # Start in first chapter, if none is set.
        currentChapterClass = @constructor.chapters()[0]

      # Instantiate the chapter.
      new currentChapterClass
    ,
      true

  destroy: ->
    @currentChapter.stop()

  id: ->
    @constructor.id()
