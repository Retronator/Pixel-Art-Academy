AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.Actions.Open extends FM.Action
  @id: -> 'LandsOfIllusions.Assets.Editor.Actions.Open'
  @displayName: -> "Open"

  @initialize()
    
  execute: ->
    dialog =
      type: LOI.Assets.Editor.AssetOpenDialog.id()
      left: position.left / scale
      top: (position.top + $item.outerHeight()) / scale
      canDismiss: true

    @interface.displayDialog dialog
