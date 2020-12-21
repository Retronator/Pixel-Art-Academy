AM = Artificial.Mirage
PAA = PixelArtAcademy
Quill = AM.Quill

class PAA.StudyGuide.Article.Task.Upload extends PAA.StudyGuide.Article.Task
  @id: -> 'PixelArtAcademy.StudyGuide.Article.Task.Upload'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @registerBlot
    name: 'studyguide-task-upload'
    tag: 'div'
    class: 'pixelartacademy-studyguide-article-task-upload'

  mixins: -> [
    PAA.Components.AutoScaledImageMixin
  ]

  onCreated: ->
    super arguments...

    @submissionPreview = new ReactiveField null
    @submissionUpload = new ReactiveField null

    @examplesFigureValue = new ComputedField =>
      @value()?.examplesFigure
    ,
      EJSON.equals

    @examplesFigure = new ReactiveField null
    @examplesHovered = new ReactiveField false

  onRendered: ->
    super arguments...

    $figureNode = @$('.pixelartacademy-studyguide-article-figure')
    figureNode = $figureNode[0]

    examplesFigure = new PAA.StudyGuide.Article.Figure figureNode, @examplesFigureValue()
    @examplesFigure examplesFigure
    
    # Reactively update the figure.
    @autorun (computation) =>
      return unless examplesFigure.isCreated()
      examplesFigure.value @examplesFigureValue()

    # Reactively update the quill component.
    @autorun (computation) =>
      return unless examplesFigure.isCreated()
      examplesFigure.quillComponent @quillComponent()

    # Listen for figure changes.
    @autorun (computation) =>
      return unless examplesFigure.isCreated()

      currentExamplesFigureValue = @examplesFigureValue()
      newExamplesFigureValue = examplesFigure.value()

      return if EJSON.equals currentExamplesFigureValue, newExamplesFigureValue

      Tracker.nonreactive =>
        value = @value()
        value.examplesFigure = newExamplesFigureValue
        @value value

  autoScaledImageMaxHeight: ->
    # Uploaded images in the guide are limited to half the book height.
    return unless article = @quillComponent()
    return unless book = article.book()
    book.design.size.height / 2

  autoScaledImageDisplayScale: ->
    return unless article = @quillComponent()
    article.bookComponent.display.scale()

  multipleExamples: ->
    @examplesFigureValue()?.elements?.length > 1

  submissionPictureSource: ->
    @task.entry()?.upload?.picture.url or @submissionPreview()

  submissionUploadingStyle: ->
    return unless submissionUpload = @submissionUpload()
    progress = submissionUpload.progress()

    width: if _.isNaN progress then 0 else "#{progress * 46}rem"

  submissionHiddenClass: ->
    'hidden' if @examplesHovered() and not @submissionUpload()

  events: ->
    super(arguments...).concat
      'click .enabled.confirmation': @onClickConfirmation
      'click .submission-upload-button': @onClickSubmissionUploadButton
      'click .remove-button': @onClickRemoveButton
      'click .submission .picture': @onClickSubmissionPicture
      'mouseenter .examples': @onMouseEnterExamples
      'mouseleave .examples': @onMouseLeaveExamples

  onClickConfirmation: (event) ->
    @ensureSignedIn =>
      # See if the task is active (the user is trying to complete it).
      if @task.active()
        @_startSubmission()

      # See if the task is completed (the user might want to undo it).
      else if entry = @task.entry()
        @attemptToRemoveTaskEntry entry

  onClickSubmissionUploadButton: (event) ->
    @ensureSignedIn =>
      @_startSubmission()

  _startSubmission: ->
    return if @submissionUpload()

    $fileInput = $('<input type="file"/>')

    $fileInput.on 'change', (event) =>
      return unless file = $fileInput[0]?.files[0]

      # Load submissionPreview file.
      reader = new FileReader()
      reader.onload = (event) => @submissionPreview event.target.result

      reader.readAsDataURL file

      # Upload file.
      upload = PAA.Practice.Journal.Entry.pictureUploadContext.upload file, (pictureUrl) =>
        # Create the entry with this picture URL.
        PAA.Learning.Task.Entry.insertForUser @task.id(),
          upload:
            picture:
              url: pictureUrl

        @submissionPreview null
        @submissionUpload null
      ,
        (error) =>
          console.error error

          @submissionPreview null
          @submissionUpload null

      @submissionUpload upload

    $fileInput.click()

  onClickRemoveButton: (event) ->
    return unless entry = @task.entry()

    @attemptToRemoveTaskEntry entry

  onClickSubmissionPicture: (event) ->
    artworks = [
      image: event.target
    ]

    article = @quillComponent()
    article.bookComponent.focusArtworks artworks

  onMouseEnterExamples: (event) ->
    @examplesHovered true

  onMouseLeaveExamples: (event) ->
    @examplesHovered false
