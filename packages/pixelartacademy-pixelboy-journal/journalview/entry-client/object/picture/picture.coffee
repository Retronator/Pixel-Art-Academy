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
      'click .retry-upload-button': @onClickRetryUploadButton

  onClickRetryUploadButton: (event) ->
    value = @value()
    return unless value.file instanceof Blob

    @uploadError null
    @_uploadFile value.file
