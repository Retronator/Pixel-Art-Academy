AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Actions.DeleteNode extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.Actions.DeleteNode'
  @displayName: -> "Delete node"
  
  @initialize()

  enabled: ->
    super(arguments...) and @_nodeIdToDelete()
    
  execute: ->
    loader = @interface.getLoaderForActiveFile()
    loader.removeNode @_nodeIdToDelete()
    
  _nodeIdToDelete: ->
    audioCanvas = @interface.getEditorForActiveFile()
    audioCanvas.selectedNodeId() or audioCanvas.hoveredNodeId()
