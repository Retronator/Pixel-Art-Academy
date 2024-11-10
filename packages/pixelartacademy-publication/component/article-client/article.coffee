AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Quill = AM.Quill
Block = Quill.import 'blots/block'

class PAA.Publication.Component.Article extends AM.Component
  @id: -> 'PixelArtAcademy.Publication.Component.Article'
  @register @id()

  @version: -> '0.1.0'

  onCreated: ->
    super arguments...

    @parentComponent = @ancestorComponentOfType PAA.StudyGuide.Pages.Home.Book
    @publication = new ComputedField => @parentComponent.publication()

    @quill = new AE.ReactiveWrapper null

    # Subscribe to the article.
    @autorun (computation) =>
      PAA.Publication.Part.articleForActivityId.subscribe @, @activity()._id

  onRendered: ->
    super arguments...

    # Initialize quill.
    quill = new Quill @$('.contents')[0],
      formats: PAA.StudyGuide.Article.quillFormats
      readOnly: true

    @quill quill

    quill.on 'text-change', (delta, oldDelta, source) =>
      # Tell the blots they are part of this component.
      for blot in @quill().getLines()
        blot.domNode.component?.quillComponent @

    # Update quill content.
    @autorun (computation) =>
      return unless activity = @activity()

      quill.setContents activity.article, Quill.sources.API

  contentUpdated: ->
    @parentComponent.contentUpdated()
