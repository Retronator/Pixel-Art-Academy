LOI = LandsOfIllusions

class LOI.Adventure.Chapter extends LOI.Adventure.Thing
  @register 'LandsOfIllusions.Adventure.Chapter'
  template: -> 'LandsOfIllusions.Adventure.Chapter'

  @number: -> throw new AE.NotImplementedException
  number: -> @constructor.number()

  @sections: -> throw new AE.NotImplementedException

  constructor: (@options) ->
    super

    @episode = @options.episode

    @sections = for sectionClass in @constructor.sections()
      new sectionClass chapter: @
      
  destroy: ->
    super

    section.destroy() for section in @sections
    @sections = []

  currentSections: ->
    section for section in @sections when section.active()

  ready: ->
    # Chapter is ready when all its sections are ready.
    conditions = _.flattenDeep [
      super
      (section.ready() for section in @sections)
    ]

    _.every conditions
        
  chapterTitle: ->
    @childComponentsOfType(LOI.Components.ChapterTitle)[0]

  showChapterTitle: (options) ->
    chapterTitle = @chapterTitle()
    chapterTitle.activatable.activate()

    # Wait till chapter title gets activated.
    @autorun (computation) =>
      return unless chapterTitle.activatable.activated()
      computation.stop()

      options.onActivated?()
