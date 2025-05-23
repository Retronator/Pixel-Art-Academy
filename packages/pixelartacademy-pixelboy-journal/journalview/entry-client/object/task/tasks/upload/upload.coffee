AM = Artificial.Mirage
PAA = PixelArtAcademy
Entry = PAA.PixelBoy.Apps.Journal.JournalView.Entry

class Entry.Object.Task.Upload extends Entry.Object.Task.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry.Object.Task.Upload'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  constructor: (@parent) ->
    super arguments...
  
  onCreated: ->
    super arguments...

    @preview = new ReactiveField null
    @uploading = new ReactiveField false

  pictureSource: ->
    @parent.taskEntry()?.upload?.picture.url or @preview()

  showUpload: ->
    @active() or @parent.completed()
  
  events: ->
    super(arguments...).concat
      'click .picture': @onClickPicture
      'click .insert-picture-button': @onClickInsertPictureButton

  onClickPicture: (event) ->
    artworks = [
      image: event.target
    ]

    # Create the stream component.
    stream = new PAA.PixelBoy.Apps.Journal.JournalView.Entry.ArtworksStream artworks

    LOI.adventure.showActivatableModalDialog
      dialog: stream

  onClickInsertPictureButton: (event) ->
    $fileInput = $('<input type="file"/>')

    $fileInput.on 'change', (event) =>
      return unless file = $fileInput[0]?.files[0]
  
      # Load preview file.
      reader = new FileReader()
      reader.onload = (event) => @preview event.target.result
  
      reader.readAsDataURL file

      @uploading true

      # Upload file.
      PAA.Practice.Journal.Entry.pictureUploadContext.upload file, (pictureUrl) =>
        # Create the entry with this picture URL.
        PAA.Learning.Task.Entry.insert LOI.characterId(), LOI.adventure.currentSituationParameters(), @parent.task.id(),
          upload:
            picture:
              url: pictureUrl
        ,
          (error) =>
            if error
              console.error error
              return

            @uploading false

    $fileInput.click()
