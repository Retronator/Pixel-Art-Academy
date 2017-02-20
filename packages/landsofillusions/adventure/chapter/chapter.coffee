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
      
    @chapterTitle = new ReactiveField null

  getSection: (sectionOrId) ->
    sectionId = _.thingId sectionOrId

    _.find @sections, (section) => section.id() is sectionId
      
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

  showChapterTitle: (options = {}) ->
    # Create new chapter title.
    chapterTitle = new LOI.Components.ChapterTitle options
    @chapterTitle chapterTitle

    # Wait till chapter title gets rendered.
    @autorun (computation) =>
      return unless chapterTitle.isRendered()
      computation.stop()

      chapterTitle.activatable.activate()

    # Wait till chapter title gets activated.
    @autorun (computation) =>
      return unless chapterTitle.activatable.activated()
      computation.stop()

      options.onActivated?()
