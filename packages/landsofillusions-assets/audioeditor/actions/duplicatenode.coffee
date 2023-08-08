AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Actions.DuplicateNode extends LOI.Assets.Editor.Actions.AssetAction
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.Actions.DuplicateNode'
  @displayName: -> "Duplicate node"

  @initialize()
  
  enabled: ->
    super(arguments...) and @_nodeIdToDuplicate()
    
  execute: ->
    loader = @interface.getLoaderForActiveFile()
    loader.duplicateNode @_nodeIdToDuplicate()
    
  _nodeIdToDuplicate: ->
    audioCanvas = @interface.getEditorForActiveFile()
    audioCanvas.selectedNodeId() or audioCanvas.hoveredNodeId()
