AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Adventure.Episode
  @id: -> throw new AE.NotImplementedException
  @chapters: -> throw new AE.NotImplementedException

  @_episodeClassesById = {}

  @getClassForId: (id) ->
    @_episodeClassesById[id]

  @initialize: ->
    @_episodeClassesById[@id()] = @

  constructor: ->
    # State object for this episode.
    @address = new LOI.StateAddress "storylines.#{@id()}"
    @stateObject = new LOI.StateObject
      address: @address

    @currentChapter = new ComputedField =>
      currentChapterId = @stateObject 'currentChapter'

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
