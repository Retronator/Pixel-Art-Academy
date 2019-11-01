AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.Open extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Open'
  @displayName: -> "Open"

  @initialize()
    
  execute: ->
    @interface.displayDialog
      contentComponentId: LOI.Assets.Editor.AssetOpenDialog.id()
