PAA = PixelArtAcademy
Entry = PAA.PixelBoy.Apps.Journal.JournalView.Entry

Quill = require 'quill'
BlockEmbed = Quill.import 'blots/block/embed'

class Entry.Object.Image extends Entry.Object
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry.Object.Image'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @registerBlot
    name: 'image'
    tag: 'p'
    class: 'pixelartacademy-pixelboy-apps-journal-journalview-entry-object-image'

  onCreated: ->
    super

    @imagePreview = new ReactiveField null

    # Handle preview and uploading.
    @autorun (computation) =>
      value = @value()

      if value.file instanceof Blob
        @_loadFilePreview value.file
        @_uploadFile value.file

  _loadFilePreview: (file) ->
    reader = new FileReader()
    reader.onload = (event) => @imagePreview event.target.result

    reader.readAsDataURL file

  _uploadFile: (file) ->
    PAA.Practice.Journal.Entry.imageUploadContext.upload file, (imageUrl) =>
      # Replace the source of the image.
      @value url: imageUrl

  imageSource: ->
    value = @value()
    value.url or @imagePreview()

  missingImageSource: ->
    value = @value()

    # Image is missing if we have a file that isn't a blob and if there is no source.
    not (value.file instanceof Blob) and not value.url
