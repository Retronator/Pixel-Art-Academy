AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Quill = require 'quill'
Block = Quill.import 'blots/block'

class PAA.StudyGuide.Pages.Admin.Activities.Activity.Article extends AM.Component
  @id: -> 'PixelArtAcademy.StudyGuide.Pages.Admin.Activities.Activity.Article'
  @register @id()

  @version: -> '0.1.0'

  @debug = false

  onCreated: ->
    super arguments...

    @activityComponent = @ancestorComponentOfType PAA.StudyGuide.Pages.Admin.Activities.Activity

    @quill = new AE.ReactiveWrapper null

    @article = new ComputedField =>
      @activityComponent.data().article or []

    @displayScale = 2

  onRendered: ->
    super arguments...

    @$article = @$('.pixelartacademy-pixelboy-apps-journal-journalview-article')

    # Initialize quill.
    quill = new Quill @$('.writing-area')[0],
      theme: 'snow'
      formats: [
        'bold'
        'italic'
        'strike'
        'underline'
        'script'
        'link'
        'code'
        'blockquote'
        'header'
        'list'
        'code-block'
        'image'
        'video'

        'picture'
        'task'
      ]
      modules:
        toolbar: [
          [{'header': [1, 2, 3, 4, false]}]
          ['bold', 'italic', 'underline', 'strike', {'script': 'sub'}, {'script': 'super'}]
          ['link', 'code']
          [{'list': 'ordered'}, {'list': 'bullet'}]
          ['blockquote', 'code-block']
          ['image', 'video']
          ['clean']
        ]

    @quill quill

    quill.on 'text-change', (delta, oldDelta, source) =>
      console.log "Text change", delta, oldDelta, source if @constructor.debug

      # Tell the blots they are part of this component.
      for blot in @quill().getLines()
        blot.domNode.component?.articleComponent @

      # Update the article if this was a user update.
      if source is Quill.sources.USER
        console.log "Updating article" if @constructor.debug
        activity = @activityComponent.data()
        PAA.StudyGuide.Activity.updateArticle activity._id, delta.ops

    quill.on 'editor-change', =>
      # Trigger reactive updates.
      @quill.updated()

    # Update quill content.
    @autorun (computation) =>
      return unless article = @article()

      # See if we already have the correct content.
      currentArticle = quill.getContents().ops

      console.log "Updating article from database", article, currentArticle if @constructor.debug

      if EJSON.equals article, currentArticle
        console.log "Current content matches." if @constructor.debug
        return

      console.log "Updating content." if @constructor.debug

      # The content is new, update.
      quill.setContents article, Quill.sources.API

  focus: ->
    @quill().focus()

  moveCursorToEnd: ->
    end = @quill().getLength()
    @quill().setSelection end, 0
