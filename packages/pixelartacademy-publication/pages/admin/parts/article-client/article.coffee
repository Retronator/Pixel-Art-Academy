AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Quill = AM.Quill

icons = Quill.import 'ui/icons'
icons['publication-figure'] = 'FG'

class PAA.Publication.Pages.Admin.Parts.Part.Article extends AM.Component
  @id: -> 'PixelArtAcademy.Publication.Pages.Admin.Parts.Part.Article'
  @register @id()

  @version: -> '0.1.0'

  @debug = false

  onCreated: ->
    super arguments...

    @partComponent = @ancestorComponentOfType PAA.Publication.Pages.Admin.Parts.Part

    @quill = new AE.ReactiveWrapper null

    @article = new ComputedField =>
      @partComponent.data().article or []

    @displayScale = 2

  onRendered: ->
    super arguments...

    # Initialize quill.
    quill = new Quill @$('.writing-area')[0],
      scrollingContainer: document.documentElement
      theme: 'snow'
      formats: PAA.Publication.Article.quillFormats
      modules:
        toolbar:
          container: [
              [{'header': [1, 2, 3, 4, false]}]
              ['bold', 'italic', 'underline', 'strike', {'script': 'sub'}, {'script': 'super'}]
              ['link', 'code']
              [{'list': 'ordered'}, {'list': 'bullet'}]
              ['blockquote', 'code-block']
              ['image']
              ['clean']
            ]
          handlers:
            image: (value) => @onQuillToolbarImageClick value

    @quill quill

    quill.on 'text-change', (delta, oldDelta, source) =>
      console.log "Text change", delta, oldDelta, source if @constructor.debug

      # Tell the blots they are part of this component.
      for blot in @quill().getLines()
        blot.domNode.component?.quillComponent @

      # Update the article if this was a user update.
      if source is Quill.sources.USER
        console.log "Updating article" if @constructor.debug
        part = @partComponent.data()
        PAA.Publication.Part.updateArticle part._id, delta.ops

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

  onQuillToolbarImageClick: ->
    quill = @quill()
    range = quill.getSelection()
    
    # Use the browser input dialog box to ask for a URL.
    urls = prompt ('Insert comma-separated image URLs').split ','

    # Insert a figure with the images in a row.
    figure =
      layout: [urls.length]
      elements: (image: {url} for url in urls)

    quill.insertEmbed range.index, 'publication-figure', figure, Quill.sources.USER
