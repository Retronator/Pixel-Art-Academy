AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Quill = AM.Quill

icons = Quill.import 'ui/icons'
icons['studyguide-practicesection'] = 'PS'
icons['studyguide-prerequisiteswarning'] = 'PW'
icons['studyguide-task-reading'] = 'TR'
icons['studyguide-task-upload'] = 'TU'

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

    @$article = @$('.pixelartacademy-pixelpad-apps-journal-journalview-article')

    # Initialize quill.
    quill = new Quill @$('.writing-area')[0],
      theme: 'snow'
      formats: PAA.StudyGuide.Article.quillFormats
      modules:
        toolbar:
          container: [
              [{'header': [1, 2, 3, 4, false]}]
              ['bold', 'italic', 'underline', 'strike', {'script': 'sub'}, {'script': 'super'}]
              ['link', 'code']
              [{'list': 'ordered'}, {'list': 'bullet'}]
              ['blockquote', 'code-block']
              ['image', 'video']
              [
                'studyguide-practicesection'
                'studyguide-prerequisiteswarning'
                'studyguide-task-reading'
                'studyguide-task-upload'
              ]
              ['clean']
            ]
          handlers:
            image: (value) => @onQuillToolbarImageClick value
            'studyguide-prerequisiteswarning': (value) => @onQuillToolbarPrerequisitesWarningClick value
            'studyguide-task-reading': (value) => @onQuillToolbarTaskReadingClick value
            'studyguide-task-upload': (value) => @onQuillToolbarTaskUploadClick value

    @quill quill

    quill.on 'text-change', (delta, oldDelta, source) =>
      console.log "Text change", delta, oldDelta, source if @constructor.debug

      # Tell the blots they are part of this component.
      for blot in @quill().getLines()
        blot.domNode.component?.quillComponent @

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

  onQuillToolbarImageClick: ->
    quill = @quill()
    range = quill.getSelection()

    $fileInput = $('<input type="file" multiple/>')

    $fileInput.on 'change', (event) =>
      return unless files = $fileInput[0]?.files

      # Insert a figure with the images in a row.
      figure =
        layout: [files.length]
        elements: (image: {file} for file in files)

      quill.insertEmbed range.index, 'figure', figure, Quill.sources.USER

    $fileInput.click()

  onQuillToolbarPrerequisitesWarningClick: (value) ->
    quill = @quill()
    range = quill.getSelection()

    return unless id = prompt 'Insert task with ID'
    task = {id}

    quill.insertEmbed range.index, 'studyguide-prerequisiteswarning', task, Quill.sources.USER

  onQuillToolbarTaskReadingClick: (value) ->
    @_insertEmbedTask 'studyguide-task-reading'

  onQuillToolbarTaskUploadClick: (value) ->
    @_insertEmbedTask 'studyguide-task-upload',
      examplesFigure:
        layout: []
        elements: []

  _insertEmbedTask: (format, task = {}) ->
    quill = @quill()
    range = quill.getSelection()

    return unless id = prompt 'Insert task with ID'
    task.id = id

    quill.insertEmbed range.index, format, task, Quill.sources.USER
