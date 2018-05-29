AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.References extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Components.References'

  @register @id()
  template: -> @constructor.id()

  @referenceUploadContext = new LOI.Assets.Upload.Context
    name: "#{@id()}.reference"
    folder: 'references'
    maxSize: 10 * 1024 * 1024 # 10 MB
    fileTypes: [
      'image/png'
      'image/jpeg'
      'image/gif'
    ]
    
  constructor: (@options) ->
    super
    
  onCreated: ->
    super

    @assetData = new ComputedField =>
      assetId = @options.assetId()
      @options.documentClass.documents.findOne assetId,
        fields:
          references: 1
          
    @uploadingReferences = new ReactiveField []
    
    @references = new ComputedField =>
      return [] unless assetData = @assetData()

      assetReferences = assetData.references or []

      # Merge existing and uploading references.
      [assetReferences..., @uploadingReferences()...]
      
  storedReferences: -> _.filter @references(), (reference) => not reference.displayed
  displayedReferences: -> _.filter @references(), (reference) => reference.displayed

  styleClasses: -> '' # Overrdide to provide custom style classes
    
  events: ->
    super.concat
      'click .upload-button': @onClickUploadButton
      'click .storage-button': @onClickStorageButton

  onClickUploadButton: (event) ->
    $fileInput = $('<input type="file"/>')

    $fileInput.on 'change', (event) =>
      return unless file = $fileInput[0]?.files[0]

      value = {file}
      quill.insertEmbed range.index, 'picture', value, Quill.sources.USER

    $fileInput.click()

  onClickStorageButton: (event) ->
    # TODO

  class @Reference extends AM.Component
    @register 'LandsOfIllusions.Assets.Components.References.Reference'

    onCreated: ->
      super
  
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

    imageSource: ->
      value = @value()
      value.url or @preview()
