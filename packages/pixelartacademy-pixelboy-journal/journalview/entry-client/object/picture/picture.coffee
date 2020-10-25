AS = Artificial.Spectrum
PAA = PixelArtAcademy
Entry = PAA.PixelBoy.Apps.Journal.JournalView.Entry

class Entry.Object.Picture extends Entry.Object
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry.Object.Picture'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @registerBlot
    name: 'picture'
    tag: 'p'
    class: 'pixelartacademy-pixelboy-apps-journal-journalview-entry-object-picture'

  onCreated: ->
    super arguments...

    @imageInfo = new ReactiveField null
    @previewSource = new ReactiveField null
    @upload = new ReactiveField null
    @uploadError = new ReactiveField null

    # Handle preview and uploading.
    @autorun (computation) =>
      value = @value()

      if value.file instanceof Blob
        computation.stop()

        @_loadFilePreview value.file
        @_uploadFile value.file

  _loadFilePreview: (file) ->
    reader = new FileReader()
    reader.onload = (event) => @previewSource event.target.result

    reader.readAsDataURL file

  _uploadFile: (file) ->
    return if @upload()

    upload = PAA.Practice.Journal.Entry.pictureUploadContext.upload file, (pictureUrl) =>
      # Replace the source of the picture.
      @value url: pictureUrl
      @upload null
    ,
      (error) =>
        @uploadError error
        @upload null

    @upload upload

  pictureStyle: ->
    return unless imageInfo = @imageInfo()
    {pixelScale, width, height} = imageInfo

    # If this is not a pixel-art image, use smooth scaling and control max height through css.
    maxHeight = 140

    unless pixelScale
      return {
        imageRendering: 'auto'
        maxHeight: "#{maxHeight}rem"
      }

    # By default we want the pixel scale to match our display scale.
    displayScale = LOI.adventure.interface.display.scale()
    desiredPixelScale = displayScale

    # If the image is taller than 140px, we want to use a smaller scale.
    sourceHeight = height / pixelScale

    if sourceHeight > maxHeight
      cssScale = maxHeight * displayScale / height

      console.log "squeeze", cssScale

    else
      cssScale = desiredPixelScale / pixelScale

      console.log "do it", cssScale

    # Account for 3 pixels of padding.
    paddingRem = 3
    paddingFull = 2 * paddingRem * desiredPixelScale
    cssWidth = width * cssScale + paddingFull

    width: "#{cssWidth}px"

  uploadingClass: ->
    'uploading' if @upload()

  uploadingStyle: ->
    return unless upload = @upload()
    progress = upload.progress()

    width: if _.isNaN progress then 0 else "#{progress * 100}%"

  canRetryUpload: ->
    uploadError = @uploadError()
    uploadError.error isnt 'Upload denied'

  pictureSource: ->
    value = @value()
    value.url or @previewSource()

  missingPictureSource: ->
    value = @value()

    # Picture is missing if we have a file that isn't a blob and if there is no source.
    not (value.file instanceof Blob) and not value.url

  events: ->
    super(arguments...).concat
      'load .picture': @onLoadPicture
      'click .picture': @onClickPicture
      'click .retry-upload-button': @onClickRetryUploadButton

  onLoadPicture: (event) ->
    image = event.target

    # Detect pixel scale and resize image appropriately.
    detectPixelScaleOptions = {}

    # Mark jpegs as compressed.
    if image.src.match /\.jpe?g$/
      detectPixelScaleOptions.compressed = true

    pixelScale =  AS.PixelArt.detectPixelScale image, detectPixelScaleOptions

    @imageInfo
      pixelScale: pixelScale
      width: image.naturalWidth
      height: image.naturalHeight

  onClickPicture: (event) ->
    artworks = [
      image: event.target
    ]

    # Create the stream component.
    stream = new PAA.PixelBoy.Apps.Journal.JournalView.Entry.ArtworksStream artworks

    LOI.adventure.showActivatableModalDialog
      dialog: stream

  onClickRetryUploadButton: (event) ->
    value = @value()
    return unless value.file instanceof Blob

    @uploadError null
    @_uploadFile value.file
