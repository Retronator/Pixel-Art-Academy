AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Environments extends FM.View
  # selectedEnvironmentIndex: the index of the selected environment
  @id: -> 'LandsOfIllusions.Assets.Editor.Environments'
  @register @id()

  @environmentUploadContext = new LOI.Assets.Upload.Context
    name: "#{@id()}.environment"
    folder: 'environments'
    maxSize: 10 * 1024 * 1024 # 10 MB
    # We can't use the proper mime type images/vnd.radiance as it's not recognized by the browser.
    fileTypes: null

  onCreated: ->
    super arguments...

    @assetData = new ComputedField =>
      @interface.getLoaderForActiveFile()?.asset()

    @environments = new ComputedField =>
      # Attach indices to environments.
      for environment, index in @assetData()?.environments or []
        _.extend _.clone(environment), {index}

    @activeEnvironmentsData = new ComputedField =>
      @interface.getComponentDataForActiveFile @

  selectedClass: ->
    environment = @currentData()
    'selected' if environment.index is @activeEnvironmentsData()?.get 'selectedEnvironmentIndex'

  activeCheckedAttribute: ->
    environment = @currentData()
    'checked' if environment.active

  showRemoveButton: ->
    # We can remove a environment if one is active.
    @activeEnvironmentsData()?.get('selectedEnvironmentIndex')?

  # Events

  events: ->
    super(arguments...).concat
      'click .environment': @onClickEnvironment
      'change .active-checkbox': @onChangeActiveCheckbox
      'click .upload-button': @onClickUploadButton
      'click .remove-button': @onClickRemoveButton

  onClickEnvironment: (event) ->
    environment = @currentData()
    @activeEnvironmentsData()?.set 'selectedEnvironmentIndex', environment.index

  onChangeActiveCheckbox: (event) ->
    environment = @currentData()
    assetData = @assetData()

    checked = $(event.target).is(':checked')
    newActiveImageId = if checked then environment.image._id else null

    LOI.Assets.VisualAsset.activateEnvironment assetData.constructor.className, assetData._id, newActiveImageId

  onClickUploadButton: (event) ->
    $fileInput = $('<input type="file"/>')

    $fileInput.on 'change', (event) =>
      return unless file = $fileInput[0]?.files[0]

      LOI.Assets.Editor.Environments.environmentUploadContext.upload file, (url) =>
        # Add environment to asset.
        assetData = @assetData()
        LOI.Assets.VisualAsset.addEnvironmentByUrl assetData.constructor.className, assetData._id, null, url

    $fileInput.click()

  onClickRemoveButton: (event) ->
    # TODO
    console.error "Removing of environments not implemented."

  class @EnvironmentThumbnail extends AM.Component
    @register 'LandsOfIllusions.Assets.Editor.Environments.EnvironmentThumbnail'

    onCreated: ->
      super arguments...

      @interface = @ancestorComponentOfType FM.Interface

      # Create the hdr image when URL changes.
      @hdrImage = new ReactiveField null

      @url = new ComputedField =>
        environment = @data()
        environment.image.url

      @autorun (computation) =>
        exposureValue = @interface.getHelperForActiveFile LOI.Assets.Editor.Helpers.ExposureValue

        hdrImage = new AM.HDRImage
          source: @url()
          exposureValue: exposureValue

        @hdrImage hdrImage
