AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Quill = require 'quill'
Block = Quill.import 'blots/block'

class PAA.StudyGuide.Pages.Home.Book.Article extends AM.Component
  @id: -> 'PixelArtAcademy.StudyGuide.Pages.Home.Book.Article'
  @register @id()

  @version: -> '0.1.0'

  onCreated: ->
    super arguments...

    @bookComponent = @ancestorComponentOfType PAA.StudyGuide.Pages.Home.Book
    @book = new ComputedField => @bookComponent.book()

    @activity = new ComputedField =>
      contentItem = @data()
      contentItem.activity.refresh()
      contentItem.activity

    @goal = new ComputedField =>
      contentItem = @data()
      contentItem.goal

    @quill = new AE.ReactiveWrapper null

  onRendered: ->
    super arguments...

    # Initialize quill.
    quill = new Quill @$('.contents')[0],
      formats: PAA.StudyGuide.Article.quillFormats
      readOnly: true

    @quill quill

    # Update quill content.
    @autorun (computation) =>
      return unless activity = @activity()

      quill.setContents activity.article, Quill.sources.API
