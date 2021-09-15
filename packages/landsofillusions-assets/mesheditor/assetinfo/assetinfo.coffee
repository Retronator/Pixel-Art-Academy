AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.AssetInfo extends LOI.Assets.Editor.AssetInfo
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.AssetInfo'
  @register @id()

  onCreated: ->
    super arguments...

  class @PlaneGrid
    class @Property extends AM.DataInputComponent
      constructor: ->
        super arguments...

        @realtime = false
        @type = AM.DataInputComponent.Types.Number
        @min = 0

      load: ->
        asset = @data()
        asset.planeGrid?[@property]

      save: (value) ->
        asset = @data()

        LOI.Assets.Asset.update asset.constructor.className, asset._id,
          $set:
            "planeGrid.#{@property}": value

    class @Size extends @Property
      @register 'LandsOfIllusions.Assets.MeshEditor.AssetInfo.PlaneGrid.Size'

      constructor: ->
        super arguments...

        @property = 'size'
        @placeholder = 100

    class @Spacing extends @Property
      @register 'LandsOfIllusions.Assets.MeshEditor.AssetInfo.PlaneGrid.Spacing'

      constructor: ->
        super arguments...

        @property = 'spacing'
        @placeholder = 1

    class @Subdivisions extends @Property
      @register 'LandsOfIllusions.Assets.MeshEditor.AssetInfo.PlaneGrid.Subdivisions'

      constructor: ->
        super arguments...

        @property = 'subdivisions'
        @placeholder = 0
