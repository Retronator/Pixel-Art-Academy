AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.New extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.New'
  @displayName: -> "New"

  @initialize()

  execute: ->
    LOI.Assets.Asset.insert @interface.parent.assetClassName, (error, assetId) =>
      if error
        console.error error
        return

      # Switch editor to the new asset.
      @interface.parent.setAssetId assetId
