AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Quill = AM.Quill

icons = Quill.import 'ui/icons'
icons['publication-figure'] = 'FG'
icons['publication-tableofcontents'] = 'ToC'

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
    quill = new Quill @$('.pixelartacademy-publication-article')[0],
      theme: 'snow'
      formats: PAA.Publication.Article.quillFormats
      modules:
        toolbar:
          container: [
            [{'publication-header-heading': [1, 2, 3, false]}]
            [{'header': [1, 2, 3, 4, false]}]
            ['bold', 'italic', 'underline', 'strike', {'script': 'sub'}, {'script': 'super'}]
            ['link', 'code']
            [{'list': 'ordered'}, {'list': 'bullet'}]
            ['blockquote', 'code-block', 'small']
            ['image']
            ['publication-tableofcontents']
            ['clean']
          ]
          handlers:
            image: (value) => @onQuillToolbarImageClick value
            'publication-tableofcontents': (value) => @onQuillToolbarPublicationTableOfContentsClick value

    @quill quill

    quill.on 'text-change', (delta, oldDelta, source) =>
      console.log "Text change", delta, oldDelta, source if @constructor.debug

      # Tell the blots they are part of this component.
      for blot in @quill().getLines()
        blot.domNode.component?.quillComponent @

      # Update the article if this was a user update.
      if source is Quill.sources.USER
        part = @partComponent.data()
        PAA.Publication.Part.updateArticle part._id, delta.ops

    quill.on 'editor-change', =>
      # Trigger reactive updates.
      @quill.updated()
      
    # Add the custom class input.
    customClassInput = document.createElement 'select'
    noneOption = document.createElement 'option'
    noneOption.text = 'No class'
    noneOption.value = ''
    customClassInput.appendChild noneOption
    
    for className in PAA.Publication.Article.CustomClass.getClasses()
      option = document.createElement 'option'
      option.text = _.startCase className
      option.value = className
      customClassInput.appendChild option
    
    # Handle input changes.
    customClassInput.addEventListener 'change', (event) ->
      value = event.target.value.trim() or false
      quill.focus()
      quill.format 'publication-customclass', value, Quill.sources.USER
      
    # Update custom class input based on the selected range.
    quill.on 'editor-change', =>
      [range] = quill.selection.getRange()
      formats = if range? then quill.getFormat range else {}
      
      if className = formats['publication-customclass']
        option = customClassInput.querySelector "option[value='#{className}']"
        
        unless option
          option = document.createElement 'option'
          option.text = _.startCase className
          option.value = className
          customClassInput.appendChild option
      
        option.selected = true
        
      else
        customClassInput.value = ''
        customClassInput.selectedIndex = 0
    
    # Add the input field to the toolbar.
    toolbarContainer = quill.container.previousSibling
    toolbarContainer.appendChild customClassInput

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
    urls = prompt('Insert comma-separated image URLs').split ','

    # Insert a figure with the images in a row.
    figure =
      layout: [urls.length]
      elements: (image: {url} for url in urls)

    quill.insertEmbed range.index, 'publication-figure', figure, Quill.sources.USER
    
  onQuillToolbarPublicationTableOfContentsClick: ->
    quill = @quill()
    range = quill.getSelection()
    quill.insertEmbed range.index, 'publication-tableofcontents', {}, Quill.sources.USER
