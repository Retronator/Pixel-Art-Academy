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

    @preview = new ReactiveField null

    # Handle preview and uploading.
    @autorun (computation) =>
      value = @value()

      if value.file instanceof Blob
        @_loadFilePreview value.file
        @_uploadFile value.file

  _loadFilePreview: (file) ->
    reader = new FileReader()
    reader.onload = (event) => @preview event.target.result

    reader.readAsDataURL file

  _uploadFile: (file) ->
    PAA.Practice.Journal.Entry.pictureUploadContext.upload file, (pictureUrl) =>
      # Replace the source of the picture.
      @value url: pictureUrl

  pictureSource: ->
    value = @value()
    value.url or @preview()

  missingPictureSource: ->
    value = @value()

    # Picture is missing if we have a file that isn't a blob and if there is no source.
    not (value.file instanceof Blob) and not value.url
