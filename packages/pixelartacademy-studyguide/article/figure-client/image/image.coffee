AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.StudyGuide.Article.Figure.Image extends AM.Component
  @id: -> 'PixelArtAcademy.StudyGuide.Article.Figure.Image'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  onCreated: ->
    super arguments...

    @figure = @ancestorComponentOfType PAA.StudyGuide.Article.Figure
    @previewSource = new ReactiveField null
    @upload = new ReactiveField null
    @uploadError = new ReactiveField null

    # Handle preview and uploading.
    @autorun (computation) =>
      element = @data()
      image = element.image

      if image.file instanceof Blob
        computation.stop()
        @_loadFilePreview image.file
        @_uploadFile image.file

  _loadFilePreview: (file) ->
    reader = new FileReader()
    reader.onload = (event) => @previewSource event.target.result

    reader.readAsDataURL file

  _uploadFile: (file) ->
    # Prevent duplicate uploads.
    return if @upload()

    @figure.preventUpdates()

    endUploading = =>
      @figure.allowUpdates()
      @upload null

    upload = PAA.StudyGuide.Article.figureUploadContext.upload file, (imageUrl) =>
      # Replace the source of the picture.
      element = @data()
      @figure.updateElement element.index, url: imageUrl
      endUploading()
    ,
      (error) =>
        @uploadError error
        endUploading()

    @upload upload

  imageSource: ->
    element = @data()
    element.image.url or @previewSource()

  missingImageSource: ->
    element = @data()

    # Image is missing if we have a file that isn't a blob and if there is no source.
    not (element.image.file instanceof Blob) and not element.image.url

  uploadPercentage: ->
    return unless upload = @upload()

    progress = upload.progress()
    progress = 0 if _.isNaN progress

    "#{Math.round progress * 100}%"

  events: ->
    super(arguments...).concat
      'load img': @onLoadImage
      'click img': @onClickImage

  onLoadImage: (event) ->
    image = event.target

    # Make image fit perfectly into the row.
    $(image).parents('.element').eq(0).css
      flexGrow: image.naturalWidth / image.naturalHeight

    # Inform figure that content has updated so that the surrounding article can recalculate the number of pages.
    @figure.contentUpdated()

  onClickImage: (event) ->
    artworks = [
      image: event.target
    ]

    article = @figure.quillComponent()
    article.bookComponent.focusArtworks artworks
