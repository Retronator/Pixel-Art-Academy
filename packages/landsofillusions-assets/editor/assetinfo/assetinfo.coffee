AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.AssetInfo extends FM.View
  @id: -> 'LandsOfIllusions.Assets.Editor.AssetInfo'
  @register @id()

  onCreated: ->
    super arguments...

    @asset = new ComputedField =>
      @interface.getLoaderForActiveFile()?.asset()

  showPalette: ->
    @interface.getLoaderForActiveFile()?.paletteId

  class @Name extends AM.DataInputComponent
    @register 'LandsOfIllusions.Assets.Editor.AssetInfo.Name'

    load: ->
      asset = @data()
      asset.name

    save: (value) ->
      asset = @data()

      LOI.Assets.Asset.update asset.constructor.className, asset._id,
        $set:
          name: value

  class @Palette extends AM.DataInputComponent
    @register 'LandsOfIllusions.Assets.Editor.AssetInfo.Palette'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    onCreated: ->
      super arguments...

      LOI.Assets.Palette.all.subscribe @

      @assetInfo = @ancestorComponentOfType LOI.Assets.Editor.AssetInfo

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

      if value
        update = $set: palette: _id: value

      else
        update = $unset: palette: true

      LOI.Assets.Asset.update asset.constructor.className, asset._id, update
