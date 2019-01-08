AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Components.AssetInfo extends FM.View
  @id: -> 'LandsOfIllusions.Assets.Components.AssetInfo'
  @register @id()

  onCreated: ->
    super arguments...

    @asset = new ComputedField =>
      @interface.getEditorForActiveFile()?.asset()

  showPalette: ->
    @interface.getEditorForActiveFile().paletteId

  class @Name extends AM.DataInputComponent
    @register 'LandsOfIllusions.Assets.Components.AssetInfo.Name'

    load: ->
      asset = @data()
      asset.name

    save: (value) ->
      asset = @data()

      LOI.Assets.Asset.update asset.constructor.className, asset._id,
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

      @assetInfo = @ancestorComponentOfType LOI.Assets.Components.AssetInfo

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
      asset = @data()
      asset.palette?._id

    save: (value) ->
      asset = @data()
      asset.setPaletteId value or null
