AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Components.AssetInfo extends AM.Component
  @register 'LandsOfIllusions.Assets.Components.AssetInfo'

  constructor: (@options) ->
    super arguments...

    @assetId = @options.getAssetId

    @assetData = new ComputedField =>
      @options.documentClass.documents.findOne @assetId(),
        fields:
          name: 1
          palette: 1

    @currentIndex = new ReactiveField null

  events: ->
    super(arguments...).concat
      'click .clear-button': @onClickClearButton
      'click .delete-button': @onClickDeleteButton
      'click .duplicate-button': @onClickDuplicateButton

  onClickClearButton: (event) ->
    @options.documentClass.clear @assetId()

  onClickDeleteButton: (event) ->
    LOI.Assets.Asset.remove @options.documentClass.className, @assetId()

  onClickDuplicateButton: (event) ->
    LOI.Assets.Asset.duplicate @options.documentClass.className, @assetId(), (error, duplicateAssetId) =>
      if error
        console.error error
        return

      # Switch to the duplicate
      @options.setAssetId duplicateAssetId

  class @Name extends AM.DataInputComponent
    @register 'LandsOfIllusions.Assets.Components.AssetInfo.Name'

    load: ->
      assetData = @data()
      assetData.name

    save: (value) ->
      assetData = @data()

      assetInfo = @ancestorComponentOfType LOI.Assets.Components.AssetInfo
      LOI.Assets.Asset.update assetInfo.options.documentClass.className, assetData._id,
        $set:
          name: value

  class @Palette extends AM.DataInputComponent
    @register 'LandsOfIllusions.Assets.Components.AssetInfo.Palette'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    onCreated: ->
      super arguments...

      LOI.Assets.Palette.all.subscribe @

    options: ->
      options = for palette in LOI.Assets.Palette.documents.find().fetch()
        name: palette.name
        value: palette._id

      # Add empty option
      options.unshift
        name: ''
        value: null

      options

    load: ->
      assetData = @data()
      assetData.palette?._id

    save: (value) ->
      assetData = @data()

      if value
        update =
          $set:
            palette:
              _id: value

      else
        update = $unset: palette: true

      assetInfo = @ancestorComponentOfType LOI.Assets.Components.AssetInfo
      LOI.Assets.Asset.update assetInfo.options.documentClass.className, assetData._id, update
